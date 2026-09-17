import type { Plugin } from '@opencode-ai/plugin'

export const Aimux: Plugin = async ({ $ }) => {
  type Status = 'working' | 'blocked' | 'idle' | 'done'

  let queue = Promise.resolve()
  let previousStatus: Status | undefined
  const sessions = new Map<string, string>()
  const pending = new Map<string, string>()

  const report = (status: Status) => {
    queue = queue.then(async () => {
      if (status === previousStatus) return
      try {
        await $`aimux set ${status}`.quiet()
      } catch {
        return
      }
      previousStatus = status
      if (status === 'blocked') void $`powershell.exe -NoProfile -NonInteractive -Command '[System.Media.SystemSounds]::Hand.Play(); Start-Sleep -Seconds 1'`.quiet().catch(() => {})
      if (status === 'done') void $`powershell.exe -NoProfile -NonInteractive -Command '[System.Media.SystemSounds]::Asterisk.Play(); Start-Sleep -Seconds 1'`.quiet().catch(() => {})
    })
    return queue
  }

  const refresh = () => {
    if (pending.size) return report('blocked')
    if ([...sessions.values()].some((status) => status === 'busy' || status === 'retry')) return report('working')
    return report(sessions.size ? 'done' : 'idle')
  }

  await report('idle')

  return {
    event: async ({ event }) => {
      switch (event.type) {
        case 'session.status': {
          sessions.set(event.properties.sessionID, event.properties.status.type)
          await refresh()
          break
        }
        case 'permission.asked': {
          if (!sessions.has(event.properties.sessionID)) sessions.set(event.properties.sessionID, 'busy')
          pending.set(`permission:${event.properties.id}`, event.properties.sessionID)
          await refresh()
          break
        }
        case 'permission.replied': {
          pending.delete(`permission:${event.properties.requestID}`)
          await refresh()
          break
        }
        case 'question.asked': {
          if (!sessions.has(event.properties.sessionID)) sessions.set(event.properties.sessionID, 'busy')
          pending.set(`question:${event.properties.id}`, event.properties.sessionID)
          await refresh()
          break
        }
        case 'question.replied':
        case 'question.rejected': {
          pending.delete(`question:${event.properties.requestID}`)
          await refresh()
          break
        }
        case 'session.deleted': {
          const sessionID = 'sessionID' in event.properties ? event.properties.sessionID : event.properties.info.id
          sessions.delete(sessionID)
          for (const [requestID, owner] of pending) {
            if (owner === sessionID) pending.delete(requestID)
          }
          await refresh()
          break
        }
      }
    },
    dispose: async () => {
      await queue
      try {
        await $`aimux clear`.quiet()
      } catch {}
    },
  }
}
