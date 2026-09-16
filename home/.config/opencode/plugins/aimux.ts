import type { Plugin } from '@opencode-ai/plugin'

export const Aimux: Plugin = async ({ $ }) => {
  // one status per pane; aggregate session IDs if subagents cause false idle states.
  let queue = Promise.resolve()
  let previousStatus: string | undefined

  const report = (status?: string) => {
    queue = queue.then(async () => {
      try {
        if (status) await $`aimux set opencode ${status}`.quiet()
        else await $`aimux set opencode`.quiet()
      } catch {}
      if (status === previousStatus) return
      previousStatus = status
      if (status === 'waiting') void $`powershell.exe -NoProfile -NonInteractive -Command '[System.Media.SystemSounds]::Hand.Play(); Start-Sleep -Seconds 1'`.quiet().catch(() => {})
      if (status === 'done') void $`powershell.exe -NoProfile -NonInteractive -Command '[System.Media.SystemSounds]::Asterisk.Play(); Start-Sleep -Seconds 1'`.quiet().catch(() => {})
    })
    return queue
  }

  await report()

  return {
    event: async ({ event }) => {
      switch (event.type) {
        case 'session.status':
          if (event.properties.status.type === 'busy') await report('working')
          if (event.properties.status.type === 'idle') await report('done')
          break
        case 'permission.asked':
        case 'question.asked':
          await report('waiting')
          break
        case 'permission.replied':
        case 'question.replied':
          await report('working')
          break
        case 'session.idle':
          await report('done')
          break
      }
    },
    dispose: async () => {
      try {
        await $`aimux clear`.quiet()
      } catch {}
    },
  }
}
