import { ref, onUnmounted } from 'vue'
import type { Notification } from '@webpos/types'

interface ActionCableMessage {
  identifier?: string
  type?: string
  message?: unknown
}

interface Subscription {
  channel: string
  [key: string]: unknown
}

interface SubscriptionOptions {
  received?: (data: unknown) => void
}

export function useWebSocket(url: string) {
  const connected = ref(false)
  const error = ref<string | null>(null)
  let ws: WebSocket | null = null
  const subscriptions = new Map<string, Set<(data: unknown) => void>>()
  let reconnectTimer: ReturnType<typeof setTimeout> | null = null

  function connect() {
    if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) return

    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
    const wsUrl = url.startsWith('ws') ? url : `${protocol}//${window.location.host}${url}`

    ws = new WebSocket(wsUrl)

    ws.onopen = () => {
      connected.value = true
      error.value = null
      // Re-subscribe all active subscriptions
      subscriptions.forEach((_, identifier) => {
        ws!.send(JSON.stringify({
          command: 'subscribe',
          identifier
        }))
      })
    }

    ws.onclose = () => {
      connected.value = false
      ws = null
      // Auto-reconnect after 3 seconds
      reconnectTimer = setTimeout(connect, 3000)
    }

    ws.onerror = () => {
      error.value = 'WebSocket 连接失败'
    }

    ws.onmessage = (event) => {
      try {
        const msg: ActionCableMessage = JSON.parse(event.data)

        // Welcome and ping messages - ignore
        if (msg.type === 'welcome' || msg.type === 'ping') return

        // ActionCable broadcast: { identifier, type: "message", message }
        if (msg.identifier && msg.type === 'message' && msg.message !== undefined) {
          const handlerSet = subscriptions.get(msg.identifier)
          if (handlerSet) {
            handlerSet.forEach((fn) => fn(msg.message))
          }
        }

        // Subscription confirmations
        if (msg.type === 'confirm_subscription') {
          // Subscription confirmed
        }

        // Rejection
        if (msg.type === 'reject_subscription') {
          error.value = 'WebSocket 订阅被拒绝'
        }
      } catch {
        // ignore non-JSON messages
      }
    }
  }

  function subscribe(channel: string, params?: Record<string, unknown>, handlers?: SubscriptionOptions) {
    connect()

    const sub: Subscription = { channel, ...params }
    const identifier = JSON.stringify(sub)

    if (!subscriptions.has(identifier)) {
      subscriptions.set(identifier, new Set())
    }

    if (handlers?.received) {
      subscriptions.get(identifier)!.add(handlers.received)
    }

    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({ command: 'subscribe', identifier }))
    }
  }

  function unsubscribe(channel: string, params?: Record<string, unknown>) {
    const sub: Subscription = { channel, ...params }
    const identifier = JSON.stringify(sub)

    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({ command: 'unsubscribe', identifier }))
    }
    subscriptions.delete(identifier)
  }

  function disconnect() {
    if (reconnectTimer) {
      clearTimeout(reconnectTimer)
      reconnectTimer = null
    }
    if (ws) {
      ws.close()
      ws = null
    }
    subscriptions.clear()
  }

  onUnmounted(disconnect)

  return { connected, error, connect, disconnect, subscribe, unsubscribe }
}

export function useActionCable() {
  const { connected, error, connect, disconnect, subscribe, unsubscribe } = useWebSocket('/cable')

  function subscribeTo(channel: string, params?: Record<string, unknown>, handlers?: SubscriptionOptions) {
    subscribe(channel, params, handlers)
  }

  function unsubscribeFrom(channel: string, params?: Record<string, unknown>) {
    unsubscribe(channel, params)
  }

  return {
    connected,
    error,
    connect,
    disconnect,
    subscribe: subscribeTo,
    unsubscribe: unsubscribeFrom,
  }
}

export function useNotifications(branchId: number) {
  const notifications = ref<Notification[]>([])
  const unreadCount = ref(0)

  const { connected, subscribe, unsubscribe } = useActionCable()

  function handleNotification(data: unknown) {
    const notification = data as Notification
    notifications.value.unshift(notification)
    if (!notification.read) unreadCount.value++
    playNotificationSound()
  }

  function playNotificationSound() {
    try {
      const audio = new Audio('/assets/sounds/notification.mp3')
      audio.volume = 0.5
      audio.play()
    } catch {
      // ignore audio errors
    }
  }

  function start() {
    subscribe('NotificationChannel', { branch_id: branchId }, {
      received: handleNotification
    })
  }

  function stop() {
    unsubscribe('NotificationChannel', { branch_id: branchId })
  }

  return {
    notifications,
    unreadCount,
    connected,
    start,
    stop,
  }
}
