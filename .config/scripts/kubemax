#!/usr/bin/env bash

set -Euo pipefail

APP_NAME="kubemax"

KUBECONFIG_DIR="${KUBEMAX_KUBECONFIG_DIR:-$HOME/.kube}"
DEFAULT_CLUSTER="${KUBEMAX_DEFAULT_CLUSTER:-flex}"
DEFAULT_KUBECONFIG_FILE="$KUBECONFIG_DIR/kubemax-$DEFAULT_CLUSTER.config"
KUBECONFIG_FILE="${KUBEMAX_KUBECONFIG:-${KUBECONFIG:-$DEFAULT_KUBECONFIG_FILE}}"
KUBE_CONTEXT=""
NAMESPACE="${KUBEMAX_NAMESPACE:-}"
KUBE_LOG_EDITOR=nvim
KUBE_SPLIT_PERC=50

# Ensure a required executable exists before continuing, so the script fails fast with a clear error.
require_command() {
	command -v "$1" >/dev/null 2>&1 || {
		printf 'Missing dependency: %s\n' "$1" >&2
		exit 1
	}
}

require_command kubectl
require_command fzf
require_command tmux
require_command vim

if [[ -z "${TMUX:-}" ]]; then
	printf 'kubemax must be run inside a tmux session. Start one with: tmux new -s kubemax\n' >&2
	exit 1
fi

# Wrap kubectl with the selected kubeconfig and optional context so every cluster call stays consistent.
kubectl_cmd() {
	local args=(
		--kubeconfig "$KUBECONFIG_FILE"
	)

	if [[ -n "$KUBE_CONTEXT" ]]; then
		args+=(--context "$KUBE_CONTEXT")
	fi

	kubectl "${args[@]}" "$@"
}

# Report the active context for headers and prompts, falling back to the cluster's current context.
current_context() {
	if [[ -n "$KUBE_CONTEXT" ]]; then
		printf '%s' "$KUBE_CONTEXT"
	else
		kubectl_cmd config current-context 2>/dev/null || printf 'none'
	fi
}

# Resolve the namespace to use by preference order so pod selection starts in the most relevant scope.
current_namespace() {
	if [[ -n "$NAMESPACE" ]]; then
		printf '%s' "$NAMESPACE"
		return
	fi

	local namespace

	namespace="$(
		kubectl_cmd config view \
			--minify \
			--output 'jsonpath={..namespace}' \
			2>/dev/null || true
	)"

	if [[ -n "$namespace" ]]; then
		printf '%s' "$namespace"
		return
	fi

	namespace="$(
		kubectl_cmd get pods --all-namespaces --no-headers 2>/dev/null |
			awk '$1 !~ /^(kube-system|kube-public|kube-node-lease|local-path-storage)$/ { print $1; exit }'
	)"

	printf '%s' "${namespace:-default}"
}

# Let the user switch kubeconfig files interactively so the rest of the session targets a different cluster.
select_kubeconfig() {
	local selected

	selected="$(
		find "$KUBECONFIG_DIR" \
			-maxdepth 2 \
			-type f \
			2>/dev/null |
			sort |
			fzf \
				--prompt='kubeconfig> ' \
				--header="Current kubeconfig: $KUBECONFIG_FILE" \
				--reverse
	)" || return

	KUBECONFIG_FILE="$selected"
	KUBE_CONTEXT=""
	NAMESPACE=""
}

# Let the user switch kube contexts within the current kubeconfig without changing the file itself.
select_context() {
	local selected

	selected="$(
		kubectl \
			--kubeconfig "$KUBECONFIG_FILE" \
			config get-contexts \
			--output=name 2>/dev/null |
			fzf \
				--prompt='context> ' \
				--header="Kubeconfig: $KUBECONFIG_FILE" \
				--reverse
	)" || return

	KUBE_CONTEXT="$selected"
	NAMESPACE=""
}

# Let the user choose a namespace explicitly when the inferred/default namespace is not the right one.
select_namespace() {
	local selected

	selected="$(
		kubectl_cmd get namespaces \
			--output 'jsonpath={range .items[*]}{.metadata.name}{"\n"}{end}' |
			sort |
			fzf \
				--prompt='namespace> ' \
				--header=" Current Namespace: $(current_namespace) | Context: $(current_context)" \
				--reverse
	)" || return

	NAMESPACE="$selected"
}

# Show pods in the active namespace so the user can pick the workload to inspect or enter.
select_pod() {
	local namespace
	namespace="$(current_namespace)"

	kubectl_cmd get pods \
		--namespace "$namespace" \
		2>/dev/null |
		fzf \
			--prompt="[$namespace]> " \
			--header="Ctrl-N: namespace | Ctrl-K: kubeconfig | Ctrl-X: context | Esc: quit" \
			--header-lines=1 \
			--expect='enter,ctrl-n,ctrl-k,ctrl-x' \
			--reverse
}

# List the containers in a pod so later actions can target the correct container in multi-container pods.
pod_containers() {
	local namespace="$1"
	local pod="$2"

	kubectl_cmd get pod "$pod" \
		--namespace "$namespace" \
		--output 'jsonpath={range .spec.containers[*]}{.name}{"\n"}{end}'
}

# Choose a container automatically when possible, or prompt the user when the pod contains multiple containers.
select_container() {
	local namespace="$1"
	local pod="$2"
	local containers
	local count

	containers="$(pod_containers "$namespace" "$pod")"
	count="$(printf '%s\n' "$containers" | sed '/^$/d' | wc -l | tr -d ' ')"

	if [[ "$count" -eq 1 ]]; then
		printf '%s\n' "$containers"
		return
	fi

	printf '%s\n' "$containers" |
		fzf \
			--prompt='container> ' \
			--header="$namespace/$pod" \
			--reverse
}

# Detect the best interactive shell available in the target container so exec opens a usable prompt.
detect_shell() {
	local namespace="$1"
	local pod="$2"
	local container="$3"

	if kubectl_cmd exec \
		--namespace "$namespace" \
		--container "$container" \
		"$pod" \
		-- sh -c 'command -v bash' \
		>/dev/null 2>&1; then
		printf '/bin/bash'
	else
		printf '/bin/sh'
	fi
}

# Run a command in a tmux split while keeping kubemax active in the current pane.
run_in_split() {
	tmux split-window \
		-v \
		-l "$KUBE_SPLIT_PERC%" \
		-c "$PWD" \
		"$@"
}

# Open an interactive exec session into the chosen pod and container.
open_shell() {
	local mode="$1"
	local namespace="$2"
	local pod="$3"
	local container="$4"
	local shell
	local -a cmd

	shell="$(detect_shell "$namespace" "$pod" "$container")"
	cmd=(
		kubectl
		--kubeconfig "$KUBECONFIG_FILE"
	)

	if [[ -n "$KUBE_CONTEXT" ]]; then
		cmd+=(--context "$KUBE_CONTEXT")
	fi

	cmd+=(
		exec
		--stdin
		--tty
		--namespace "$namespace"
		--container "$container"
		"$pod"
		-- "$shell"
	)

	if [[ "$mode" == split ]]; then
		run_in_split "${cmd[@]}"
	else
		exec "${cmd[@]}"
	fi
}

# Stream container logs in the selected run mode.
follow_logs() {
	local mode="$1"
	local namespace="$2"
	local pod="$3"
	local container="$4"
	local -a cmd

	cmd=(
		kubectl
		--kubeconfig "$KUBECONFIG_FILE"
	)

	if [[ -n "$KUBE_CONTEXT" ]]; then
		cmd+=(--context "$KUBE_CONTEXT")
	fi

	cmd+=(
		logs
		--follow
		--timestamps
		--namespace "$namespace"
		--container "$container"
		"$pod"
	)

	if [[ "$mode" == split ]]; then
		run_in_split "${cmd[@]}"
	else
		exec "${cmd[@]}"
	fi
}

# Capture logs to a temp file and open them read-only in Vim for easier searching and scrolling.
logs_in_vim() {
	local mode="$1"
	local namespace="$2"
	local pod="$3"
	local container="$4"
	local logfile

	logfile="$(mktemp "${TMPDIR:-/tmp}/${APP_NAME}.XXXXXX.log")"

	kubectl_cmd logs \
		--timestamps \
		--namespace "$namespace" \
		--container "$container" \
		"$pod" >"$logfile"

	if [[ "$mode" == split ]]; then
		run_in_split "$KUBE_LOG_EDITOR -R '$logfile'; rm -f '$logfile'"
	else
		"$KUBE_LOG_EDITOR" -R "$logfile"
		rm -f "$logfile"
		exit 0
	fi
}

# Present the post-selection actions so the same pod/container choice can drive shell or log workflows.
pod_action_menu() {
	local namespace="$1"
	local pod="$2"
	local container="$3"
	local selection
	local key
	local action
	local mode

	selection="$(
		printf '%s\n' \
			'shell       Open interactive shell' \
			'follow      Follow logs' \
			'vim         Open logs in Vim' |
			fzf \
				--prompt='action> ' \
				--header="$namespace/$pod [$container] | Enter: run here | Ctrl-S: tmux split" \
				--reverse \
				--expect='enter,ctrl-s'
	)" || return

	key="$(printf '%s\n' "$selection" | sed -n '1p')"
	action="$(printf '%s\n' "$selection" | sed -n '2p')"

	case "$key" in
	enter)
		mode='current'
		;;
	ctrl-s)
		mode='split'
		;;
	*)
		return
		;;
	esac

	case "$action" in
	shell*)
		open_shell "$mode" "$namespace" "$pod" "$container"
		;;
	follow*)
		follow_logs "$mode" "$namespace" "$pod" "$container"
		;;
	vim*)
		logs_in_vim "$mode" "$namespace" "$pod" "$container"
		;;
	esac
}

# Orchestrate the interactive loop that selects cluster scope, pod, container, and then an action.
main() {
	while true; do
		local selection
		local key
		local pod
		local namespace
		local container

		selection="$(select_pod)" || exit 0

		key="$(printf '%s\n' "$selection" | sed -n '1p')"
		pod="$(printf '%s\n' "$selection" | sed -n '2p' | awk '{print $1}')"

		case "$key" in
		ctrl-n)
			select_namespace
			continue
			;;
		ctrl-k)
			select_kubeconfig
			continue
			;;
		ctrl-x)
			select_context
			continue
			;;
		enter)
			;;
		*)
			continue
			;;
		esac

		[[ -n "$pod" ]] || continue

		namespace="$(current_namespace)"
		container="$(select_container "$namespace" "$pod")" || continue

		pod_action_menu "$namespace" "$pod" "$container"
	done
}

main "$@"
