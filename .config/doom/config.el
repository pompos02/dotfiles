;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

(setq doom-theme 'modus-vivendi)
(setq doom-font (font-spec :family "Berkeley Mono" :size 38))
;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; ASCII-only UI (no nerd font icons).
(after! doom-modeline
  (setq doom-modeline-icon nil
        doom-modeline-unicode-fallback nil))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Disable autopairs
 ;; run immediately, before doom-first-buffer-hook fires
  (remove-hook 'doom-first-buffer-hook #'smartparens-global-mode)

  (after! smartparens
    (smartparens-global-mode -1))

;; List the directories of your projects (make it like the custom tmux_sessions)
  (after! projectile
    (setq projectile-project-search-path
          '("~/projects/personal"
            "~/projects/opensource")))

;; Relative line numbers
 (setq display-line-numbers-type 'relative)

;; Show line numbers in every buffer, not just prog/text/conf modes.
(global-display-line-numbers-mode 1)
;; Vim like completions
(after! corfu
  (setq corfu-auto nil))

;; Disable the command mode ghost text
(setq evil-want-empty-ex-last-command nil)

;; Vim‑style next hunk
(after! diff-hl
  (map! :n "]h" #'+vc-gutter/next-hunk
        :n "[h" #'+vc-gutter/previous-hunk))

;; Hilight words wheen hovering, here we define in which modes we should have this enabled
;; Its maybe better to to use the lsp (hilighitng)
(use-package! highlight-symbol
  ;; :hook (prog-mode . highlight-symbol-mode)
  :hook (text-mode . highlight-symbol-mode)
  :hook (conf-mode . highlight-symbol-mode)
  :hook (sql-mode . highlight-symbol-mode)
  :hook (ELisp/l-mode . highlight-symbol-mode)
  :config
  (setq highlight-symbol-idle-delay 0.2

        highlight-symbol-on-navigation-p t))

  (after! highlight-symbol
    (set-face-attribute 'highlight-symbol-face nil
                        :weight 'bold
                        :underline t
                        :background 'unspecified));;

;; make the default sql-mode product oracle
  (after! sql
    (setq sql-product 'oracle))


;; Custom oracle sql scrip
(setenv "TNS_ADMIN" "/opt/oracle/wallet")
(defun my/oracle-tns-services ()
  "Return a list of TNS service names from tnsnames.ora."
  (let* ((tns (expand-file-name "tnsnames.ora" (getenv "TNS_ADMIN"))))
    (with-temp-buffer
      (Insert-file-contents tns)
      (goto-char (point-min))
      (let (services)
        (while (re-search-forward "^\\s-*\\([^# \t\n]+\\)\\s-*=" nil t)
          (push (match-string 1) services))
        (nreverse services)))))

(defun my/sql-oracle-connect ()
  "Prompt for TNS service and connect via sqlplus."
  (interactive)
  (let* ((service (completing-read "Service: " (my/oracle-tns-services)))
         (conn-name (format "oracle:%s" service))
         (sql-connection-alist
          (cons `(,conn-name
                  (sql-product 'oracle)
                  (sql-database ,service))
                sql-connection-alist)))
    (sql-connect conn-name)))

(after! org
    (setq org-log-done 'time))   ; add CLOSED timestamp on DONE


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
