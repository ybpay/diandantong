<template>
  <div class="queue-board">
    <div class="grid grid-cols-2 gap-4">
      <div v-for="queue in queues" :key="queue.id"
        class="queue-card p-4 rounded-lg border-2"
        :class="queueClass(queue)"
      >
        <div class="flex items-center justify-between">
          <div>
            <div class="text-2xl font-bold">{{ queue.queue_no }}</div>
            <div class="text-sm text-gray-600">{{ queue.name }} · {{ queue.guest_num }}人</div>
            <div v-if="queue.phone" class="text-xs text-gray-500">{{ queue.phone }}</div>
          </div>
          <div class="text-xs text-gray-400">{{ waitTime(queue.created_at) }}</div>
        </div>
        <div class="flex gap-2 mt-3">
          <el-button v-if="queue.status === 'waiting'" type="primary" size="small" @click="emit('call', queue)">
            叫号
          </el-button>
          <el-button v-if="queue.status === 'called'" type="success" size="small" @click="emit('seat', queue)">
            入座
          </el-button>
          <el-button type="danger" size="small" text @click="emit('cancel', queue)">
            取消
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { GuestQueue } from '@webpos/types'
import { waitTime } from '@webpos/composables'

defineProps<{
  queues: GuestQueue[]
}>()

const emit = defineEmits<{
  (e: 'call', queue: GuestQueue): void
  (e: 'seat', queue: GuestQueue): void
  (e: 'cancel', queue: GuestQueue): void
}>()

function queueClass(queue: GuestQueue) {
  return {
    'waiting': 'bg-white border-gray-300',
    'called': 'bg-yellow-50 border-yellow-400',
    'seated': 'bg-green-50 border-green-400',
    'cancelled': 'bg-gray-100 border-gray-300 opacity-50',
  }[queue.status] || 'bg-gray-50 border-gray-300'
}
</script>
