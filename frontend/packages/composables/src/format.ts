import { ref } from 'vue'

export function useLoading() {
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function withLoading<T>(fn: () => Promise<T>): Promise<T | undefined> {
    loading.value = true
    error.value = null
    try {
      return await fn()
    } catch (e: unknown) {
      const err = e as { message?: string }
      error.value = err.message || '操作失败'
      throw e
    } finally {
      loading.value = false
    }
  }

  return { loading, error, withLoading }
}

export function formatPrice(price: number): string {
  return `¥${(price / 100).toFixed(2)}`
}

export function parsePrice(str: string): number {
  return Math.round(parseFloat(str.replace(/[^\d.]/g, '')) * 100)
}

export function formatTime(dateStr: string): string {
  const d = new Date(dateStr)
  return `${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`
}

export function formatDate(dateStr: string): string {
  const d = new Date(dateStr)
  return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')}`
}

export function waitTime(startTime: string): string {
  const start = new Date(startTime).getTime()
  const now = Date.now()
  const diff = Math.floor((now - start) / 60000)
  if (diff < 1) return '刚刚'
  if (diff < 60) return `${diff}分钟`
  const hours = Math.floor(diff / 60)
  const mins = diff % 60
  return `${hours}小时${mins}分钟`
}
