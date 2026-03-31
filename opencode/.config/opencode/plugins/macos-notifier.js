import { basename } from "node:path"

const SETTINGS = {
  enableNotifications: true,
  enableQuestionAlerts: true,
  notifySubagents: false,
  showSessionTitle: true,
  completeDelayMs: 400,
}

const EVENT_DEBOUNCE_MS = 1000

const pendingCompletes = new Map()
const lastAlertAt = new Map()

function getProjectTitle(directory) {
  return directory ? `OpenCode (${basename(directory)})` : "OpenCode"
}

function getSessionID(event) {
  const sessionID = event?.properties?.sessionID
  return typeof sessionID === "string" && sessionID.length > 0 ? sessionID : null
}

function encodeBase64(value) {
  return Buffer.from(String(value), "utf8").toString("base64")
}

function isKittyTerminal() {
  if (!process.stdout.isTTY) {
    return false
  }

  if (process.env.KITTY_WINDOW_ID) {
    return true
  }

  const term = typeof process.env.TERM === "string" ? process.env.TERM : ""
  const termProgram = typeof process.env.TERM_PROGRAM === "string" ? process.env.TERM_PROGRAM : ""

  return term.includes("kitty") || termProgram.toLowerCase() === "kitty"
}

function getKittyNotificationID(alertKey) {
  const cleaned = String(alertKey)
    .replace(/[^a-zA-Z0-9._-]/g, "-")
    .replace(/^-+/, "")

  return `opencode-${cleaned || Date.now()}`.slice(0, 128)
}

async function writeEscapeSequence(sequence) {
  await new Promise((resolve) => {
    process.stdout.write(sequence, () => resolve())
  })
}

async function showKittyNotification(title, message, alertKey) {
  const notificationID = getKittyNotificationID(alertKey)
  const silent = encodeBase64("silent")

  await writeEscapeSequence(`\x1b]99;i=${notificationID}:e=1:d=0:s=${silent};${encodeBase64(title)}\x1b\\`)
  await writeEscapeSequence(`\x1b]99;i=${notificationID}:e=1:p=body;${encodeBase64(message)}\x1b\\`)
}

async function showNotification(title, message, alertKey) {
  if (!SETTINGS.enableNotifications) {
    return
  }

  if (!isKittyTerminal()) {
    return
  }

  await showKittyNotification(title, message, alertKey)
}

function shouldSkipAlert(key) {
  const now = Date.now()
  const lastSeenAt = lastAlertAt.get(key)

  if (typeof lastSeenAt === "number" && now - lastSeenAt < EVENT_DEBOUNCE_MS) {
    return true
  }

  lastAlertAt.set(key, now)
  return false
}

function buildMessage(kind, sessionTitle) {
  const suffix = SETTINGS.showSessionTitle && sessionTitle ? `: ${sessionTitle}` : ""

  switch (kind) {
    case "permission":
      return `Session needs permission${suffix}`
    case "complete":
      return `Session finished${suffix}`
    case "error":
      return `Session hit an error${suffix}`
    case "question":
      return `Session has a question${suffix}`
    default:
      return `OpenCode event${suffix}`
  }
}

async function getSessionMeta(client, sessionID) {
  if (!sessionID) {
    return { title: null, isChild: false }
  }

  try {
    const response = await client.session.get({ path: { id: sessionID } })
    return {
      title: response.data?.title ?? null,
      isChild: Boolean(response.data?.parentID),
    }
  } catch {
    return { title: null, isChild: false }
  }
}

function clearPendingComplete(sessionID) {
  if (!sessionID) {
    return
  }

  const timer = pendingCompletes.get(sessionID)
  if (!timer) {
    return
  }

  clearTimeout(timer)
  pendingCompletes.delete(sessionID)
}

async function sendAlert(kind, directory, sessionTitle, alertKey) {
  if (shouldSkipAlert(alertKey)) {
    return
  }

  const title = getProjectTitle(directory)
  const message = buildMessage(kind, sessionTitle)

  await showNotification(title, message, alertKey)
}

export const MacOSNotifierPlugin = async ({ client, directory }) => {
  if (process.platform !== "darwin") {
    return {}
  }

  async function notifyForSession(kind, sessionID) {
    const meta = await getSessionMeta(client, sessionID)
    if (!SETTINGS.notifySubagents && meta.isChild) {
      return
    }

    const key = `${kind}:${sessionID ?? "global"}`
    await sendAlert(kind, directory, meta.title, key)
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.status" && event.properties?.status?.type === "busy") {
        clearPendingComplete(event.properties?.sessionID)
        return
      }

      if (event.type === "permission.asked") {
        await notifyForSession("permission", getSessionID(event))
        return
      }

      if (event.type === "session.error") {
        clearPendingComplete(getSessionID(event))

        if (event.properties?.error?.name === "MessageAbortedError") {
          return
        }

        await notifyForSession("error", getSessionID(event))
        return
      }

      if (event.type === "session.idle") {
        const sessionID = getSessionID(event)

        if (!sessionID) {
          await sendAlert("complete", directory, null, "complete:global")
          return
        }

        clearPendingComplete(sessionID)
        const timer = setTimeout(() => {
          pendingCompletes.delete(sessionID)
          void notifyForSession("complete", sessionID)
        }, SETTINGS.completeDelayMs)

        pendingCompletes.set(sessionID, timer)
      }
    },
    "tool.execute.before": async (input) => {
      if (!SETTINGS.enableQuestionAlerts || input.tool !== "question") {
        return
      }

      await sendAlert("question", directory, null, "question")
    },
  }
}

export default MacOSNotifierPlugin
