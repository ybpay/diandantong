const STATUS_TAG_TYPE: Record<string, string> = {
  pending: 'info',
  confirmed: 'warning',
  delivering: '',
  completed: 'success',
  cancelled: 'danger',
}

const STATUS_TEXT: Record<string, string> = {
  pending: '待确认',
  confirmed: '已确认',
  delivering: '配送中',
  completed: '已完成',
  cancelled: '已取消',
}

export function statusTagType(s: string): string {
  return STATUS_TAG_TYPE[s] ?? ''
}

export function statusText(s: string): string {
  return STATUS_TEXT[s] ?? s
}

export function formatTime(t: string): string {
  if (!t) return ''
  return new Date(t).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export function formatLineItems(items: { product_name: string; quantity: number }[] | undefined): string {
  if (!items?.length) return ''
  return items.map(i => `${i.product_name} x${i.quantity}`).join(', ')
}

export function useOrderHelpers() {
  return { statusTagType, statusText, formatTime, formatLineItems }
}
