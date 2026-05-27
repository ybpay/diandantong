<template>
  <div class="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-lg p-8 text-center w-full max-w-sm">
      <!-- Queue Number -->
      <div class="mb-6">
        <p class="text-sm text-gray-500">您的排号</p>
        <h1 class="text-5xl font-bold text-orange-500 mt-2">{{ queueNo }}</h1>
      </div>

      <!-- Status Info -->
      <div v-if="queueStatus" class="space-y-4">
        <van-cell-group>
          <van-cell title="前面等待" :value="`${queueStatus.ahead_count}桌`" />
          <van-cell title="预计等待" :value="queueStatus.estimated_wait" />
          <van-cell title="状态" :value="queueStatusLabel" />
        </van-cell-group>
      </div>

      <van-loading v-else class="mt-4" size="24px" vertical>加载中...</van-loading>

      <!-- Actions -->
      <div class="mt-6 flex gap-3">
        <van-button type="primary" plain block @click="router.push('/home')">
          返回首页
        </van-button>
        <van-button type="danger" plain block @click="cancelQueue">
          取消排队
        </van-button>
      </div>
    </div>

    <!-- Auto refresh -->
    <p class="mt-4 text-xs text-gray-400">每30秒自动刷新</p>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast, showDialog } from 'vant'
import { h5Client } from '@/api/client'

interface QueueStatus {
  queue_no: string
  ahead_count: number
  estimated_wait: string
  status: string
}

const router = useRouter()
const route = useRoute()
const branchId = computed(() => Number(route.params.branchId))
const queueNo = computed(() => (route.query.queue_no as string) || '')

const queueStatus = ref<QueueStatus | null>(null)
let refreshTimer: ReturnType<typeof setInterval> | null = null

const queueStatusLabel = computed(() => {
  if (!queueStatus.value) return ''
  const map: Record<string, string> = {
    waiting: '等待中',
    called: '已叫号',
    cancelled: '已取消',
    completed: '已完成',
  }
  return map[queueStatus.value.status] || queueStatus.value.status
})

async function fetchStatus(): Promise<void> {
  try {
    const { data } = await h5Client.get(`/branches/${branchId.value}/queue_status`, {
      params: { queue_no: queueNo.value },
    })
    queueStatus.value = data
    if (data.status === 'called' || data.status === 'completed') {
      if (refreshTimer) {
        clearInterval(refreshTimer)
        refreshTimer = null
      }
    }
  } catch {
    // Ignore
  }
}

async function cancelQueue(): Promise<void> {
  try {
    await showDialog({ title: '确认取消', message: '确定要取消排队吗？' })
    await h5Client.delete(`/branches/${branchId.value}/queue`, {
      params: { queue_no: queueNo.value },
    })
    showToast('已取消排队')
    router.push('/home')
  } catch {
    // User cancelled or API error
  }
}

onMounted(() => {
  fetchStatus()
  refreshTimer = setInterval(fetchStatus, 30000)
})

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
})
</script>
