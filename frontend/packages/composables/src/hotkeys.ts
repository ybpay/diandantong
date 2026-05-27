import { ref, onMounted, onUnmounted } from 'vue'

type HotkeyHandler = (e: KeyboardEvent) => void

interface HotkeyBinding {
  key: string
  ctrl?: boolean
  shift?: boolean
  alt?: boolean
  handler: HotkeyHandler
  description: string
}

const globalHotkeys = new Map<string, HotkeyBinding>()

function makeKey(e: KeyboardEvent) {
  return `${e.ctrlKey ? 'ctrl+' : ''}${e.shiftKey ? 'shift+' : ''}${e.altKey ? 'alt+' : ''}${e.key.toLowerCase()}`
}

function handleKeydown(e: KeyboardEvent) {
  const key = makeKey(e)
  const binding = globalHotkeys.get(key)
  if (binding) {
    e.preventDefault()
    binding.handler(e)
  }
}

if (typeof window !== 'undefined') {
  window.addEventListener('keydown', handleKeydown)
}

export function useHotkeys() {
  const localHotkeys = new Map<string, HotkeyBinding>()

  function register(
    key: string,
    handler: HotkeyHandler,
    options: { ctrl?: boolean; shift?: boolean; alt?: boolean; description?: string } = {}
  ) {
    const parts: string[] = []
    if (options.ctrl) parts.push('ctrl')
    if (options.shift) parts.push('shift')
    if (options.alt) parts.push('alt')
    parts.push(key.toLowerCase())
    const combo = parts.join('+')

    const binding: HotkeyBinding = {
      key: key.toLowerCase(),
      ctrl: options.ctrl,
      shift: options.shift,
      alt: options.alt,
      handler,
      description: options.description || '',
    }

    globalHotkeys.set(combo, binding)
    localHotkeys.set(combo, binding)
  }

  function unregister(key: string, options: { ctrl?: boolean; shift?: boolean; alt?: boolean } = {}) {
    const parts: string[] = []
    if (options.ctrl) parts.push('ctrl')
    if (options.shift) parts.push('shift')
    if (options.alt) parts.push('alt')
    parts.push(key.toLowerCase())
    const combo = parts.join('+')

    globalHotkeys.delete(combo)
    localHotkeys.delete(combo)
  }

  onUnmounted(() => {
    for (const combo of localHotkeys.keys()) {
      globalHotkeys.delete(combo)
    }
    localHotkeys.clear()
  })

  return { register, unregister }
}
