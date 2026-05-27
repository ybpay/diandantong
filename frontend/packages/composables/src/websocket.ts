import { ref, onUnmounted } from 'vue'
import type { Notification } from '@webpos/types'

export function useWebSocket(url: string) {
  const connected = ref(false)
  const error = ref<string | null>(null)
  let ws: WebSocket | null = null
  const handlers = new Map<string, Set<(data: unknown) => void>>()

  function connect() {
    if (ws) ws.close()

    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
    const wsUrl = url.startsWith('ws') ? url : `${protocol}//${window.location.host}${url}`

    ws = new WebSocket(wsUrl)

    ws.onopen = () => {
      connected.value = true
      error.value = null
    }

    ws.onclose = () => {
      connected.value = false
      setTimeout(connect, 3000)
    }

    ws.onerror = () => {
      error.value = 'WebSocket 连接失败'
    }

    ws.onmessage = (event) => {
      try {
        const msg = JSON.parse(event.data)
        const type = msg.type || msg.channel
        const handlerSet = handlers.get(type)
        if (handlerSet) {
          handlerSet.forEach((fn) => fn(msg.data || msg))
        }
        // Also call wildcard handlers
        const wildcardSet = handlers.get('*')
        if (wildcardSet) {
          wildcardSet.forEach((fn) => fn(msg))
        }
      } catch {
        // ignore non-JSON messages
      }
    }
  }

  function on(type: string, handler: (data: unknown) => void) {
    if (!handlers.has(type)) handlers.set(type, new Set())
    handlers.get(type)!.add(handler)
    return () => handlers.get(type)?.delete(handler)
  }

  function off(type: string, handler: (data: unknown) => void) {
    handlers.get(type)?.delete(handler)
  }

  function send(data: unknown) {
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(data))
    }
  }

  function disconnect() {
    if (ws) {
      ws.close()
      ws = null
    }
  }

  onUnmounted(disconnect)

  return { connected, error, connect, disconnect, on, off, send }
}

export function useActionCable() {
  const { connected, connect, disconnect, on, off, send } = useWebSocket('/cable')

  function subscribe(channel: string) {
    connect()
    send({ command: 'subscribe', identifier: JSON.stringify({ channel }) })
  }

  function unsubscribe(channel: string) {
    send({ command: 'unsubscribe', identifier: JSON.stringify({ channel }) })
    disconnect()
  }

  return { connected, subscribe, unsubscribe, on, off }
}

export function useNotifications(branchId: number) {
  const notifications = ref<Notification[]>([])
  const unreadCount = ref(0)

  const { connected, subscribe, unsubscribe, on } = useActionCable()

  on('notification', (data: unknown) => {
    const notification = data as Notification
    notifications.value.unshift(notification)
    if (!notification.read) unreadCount.value++
    playNotificationSound()
  })

  function playNotificationSound() {
    try {
      const audio = new Audio('/assets/sounds/notification.mp3')
      audio.volume = 0.5
      audio.play()
    } catch {
      // ignore audio errors
    }
  }

  return { notifications, unreadCount, connected, subscribe, unsubscribe }
}
