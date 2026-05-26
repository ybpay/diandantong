import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Notification } from '@webpos/types'
import { notificationApi } from '@webpos/api'

export const useNotificationStore = defineStore('notification', () => {
  const notifications = ref<Map<number, Notification[]>>(new Map())

  function getBranchNotifications(branchId: number) {
    return computed(() => notifications.value.get(branchId) || [])
  }

  function unreadCount(branchId: number) {
    const list = notifications.value.get(branchId) || []
    return list.filter((n) => !n.read).length
  }

  async function fetchNotifications(branchId: number) {
    const { data } = await notificationApi.list(branchId)
    notifications.value.set(branchId, data)
  }

  async function markRead(branchId: number, notificationId: string) {
    await notificationApi.markRead(branchId, notificationId)
    const list = notifications.value.get(branchId) || []
    const item = list.find((n) => n.id === notificationId)
    if (item) item.read = true
  }

  async function clearAll(branchId: number) {
    await notificationApi.clear(branchId)
    notifications.value.set(branchId, [])
  }

  function addNotification(branchId: number, notification: Notification) {
    const list = notifications.value.get(branchId) || []
    list.unshift(notification)
    notifications.value.set(branchId, list)
  }

  return {
    notifications,
    getBranchNotifications,
    unreadCount,
    fetchNotifications,
    markRead,
    clearAll,
    addNotification,
  }
})
