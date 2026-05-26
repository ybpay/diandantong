<template>
  <div class="pos-layout h-screen flex flex-col bg-gray-100">
    <header class="pos-header flex items-center justify-between bg-primary-600 text-white px-4 py-2 shadow-md">
      <div class="flex items-center gap-4">
        <h1 class="text-lg font-bold">{{ title }}</h1>
        <span v-if="branchName" class="text-sm opacity-80">{{ branchName }}</span>
      </div>
      <div class="flex items-center gap-4">
        <slot name="header-actions" />
        <NotificationBell v-if="showNotifications" :branch-id="branchId" />
        <span class="text-sm">{{ currentTime }}</span>
        <el-dropdown @command="handleCommand">
          <span class="cursor-pointer">
            {{ userName }} <el-icon><arrow-down /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="settings">设置</el-dropdown-item>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>
    <main class="flex-1 overflow-hidden">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { ArrowDown } from '@element-plus/icons-vue'
import NotificationBell from '../NotificationBell/NotificationBell.vue'

defineProps<{
  title: string
  branchName?: string
  branchId?: number
  userName?: string
  showNotifications?: boolean
}>()

const emit = defineEmits<{
  (e: 'command', command: string): void
}>()

const currentTime = ref('')

let timer: ReturnType<typeof setInterval>

function updateTime() {
  const now = new Date()
  currentTime.value = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')} ${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`
}

function handleCommand(command: string) {
  emit('command', command)
}

onMounted(() => {
  updateTime()
  timer = setInterval(updateTime, 1000)
})

onUnmounted(() => {
  clearInterval(timer)
})
</script>
