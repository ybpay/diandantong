<template>
  <el-popover placement="bottom" :width="300" trigger="click">
    <template #reference>
      <el-badge :value="unreadCount" :hidden="unreadCount === 0" class="cursor-pointer">
        <el-icon :size="20"><bell /></el-icon>
      </el-badge>
    </template>
    <div class="max-h-80 overflow-y-auto">
      <div v-if="notifications.length === 0" class="text-center text-gray-400 py-4">
        暂无通知
      </div>
      <div
        v-for="n in notifications.slice(0, 20)"
        :key="n.id"
        class="p-2 border-b border-gray-100 last:border-0"
        :class="{ 'bg-blue-50': !n.read }"
      >
        <div class="text-sm font-medium">{{ n.title }}</div>
        <div class="text-xs text-gray-500">{{ n.content }}</div>
        <div class="text-xs text-gray-400 mt-1">{{ formatTime(n.created_at) }}</div>
      </div>
    </div>
  </el-popover>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { Bell } from '@element-plus/icons-vue'
import { useNotificationStore } from '@webpos/stores'
import { formatTime } from '@webpos/composables'

const props = defineProps<{
  branchId?: number
}>()

const notificationStore = useNotificationStore()

const notifications = computed(() => {
  if (!props.branchId) return []
  return notificationStore.getBranchNotifications(props.branchId).value
})

const unreadCount = computed(() => {
  if (!props.branchId) return 0
  return notificationStore.unreadCount(props.branchId)
})

onMounted(() => {
  if (props.branchId) {
    notificationStore.fetchNotifications(props.branchId)
  }
})
</script>
