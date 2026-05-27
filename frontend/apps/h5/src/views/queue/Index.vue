<template>
  <div class="min-h-screen bg-gray-50">
    <van-nav-bar
      title="排队取号"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <!-- Branch Selector -->
    <van-cell-group class="mt-2" title="选择门店">
      <van-cell
        :title="selectedBranch?.name || '请选择门店'"
        is-link
        @click="showBranchPicker = true"
      />
    </van-cell-group>

    <!-- Guest Count -->
    <van-cell-group class="mt-2" title="用餐人数">
      <div class="p-4">
        <van-stepper v-model="guestCount" min="1" max="20" />
        <p class="mt-2 text-sm text-gray-500">当前人数：{{ guestCount }}人</p>
      </div>
    </van-cell-group>

    <!-- Queue Info -->
    <div v-if="queueInfo" class="bg-white mt-2 p-4">
      <van-cell-group title="排队信息">
        <van-cell title="当前等待" :value="`${queueInfo.waiting_count}桌`" />
        <van-cell title="预计等待" :value="queueInfo.estimated_wait" />
      </van-cell-group>
    </div>

    <!-- Take Number Button -->
    <div class="p-6">
      <van-button
        type="danger"
        block
        round
        size="large"
        :disabled="!selectedBranch"
        :loading="submitting"
        @click="takeNumber"
      >
        取号排队
      </van-button>
    </div>

    <!-- Branch Picker -->
    <van-action-sheet v-model:show="showBranchPicker">
      <van-picker
        :columns="branchColumns"
        @confirm="onBranchConfirm"
        @cancel="showBranchPicker = false"
      />
    </van-action-sheet>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'
import { h5Client } from '@/api/client'

interface Branch {
  id: number
  name: string
}

interface QueueInfo {
  waiting_count: number
  estimated_wait: string
}

const router = useRouter()
const route = useRoute()
const branchId = computed(() => Number(route.params.branchId))

const branches = ref<Branch[]>([])
const selectedBranch = ref<Branch | null>(null)
const guestCount = ref(2)
const queueInfo = ref<QueueInfo | null>(null)
const showBranchPicker = ref(false)
const submitting = ref(false)

const branchColumns = computed(() =>
  branches.value.map((b) => ({ text: b.name, value: b.id }))
)

onMounted(async () => {
  try {
    const { data } = await h5Client.get('/branches')
    branches.value = data
    const found = branches.value.find((b) => b.id === branchId.value)
    if (found) {
      selectedBranch.value = found
      await fetchQueueInfo()
    }
  } catch {
    // Use empty list
  }
})

async function fetchQueueInfo(): Promise<void> {
  if (!selectedBranch.value) return
  try {
    const { data } = await h5Client.get(`/branches/${selectedBranch.value.id}/queue_info`, {
      params: { guest_count: guestCount.value },
    })
    queueInfo.value = data
  } catch {
    // Ignore
  }
}

function onBranchConfirm({ selectedOptions }: any): void {
  selectedBranch.value = selectedOptions[0] as Branch
  showBranchPicker.value = false
  fetchQueueInfo()
}

async function takeNumber(): Promise<void> {
  if (!selectedBranch.value) return
  submitting.value = true
  try {
    const { data } = await h5Client.post('/queues', {
      branch_id: selectedBranch.value.id,
      guest_count: guestCount.value,
    })
    showToast('取号成功')
    router.replace(`/queue/${selectedBranch.value.id}/status?queue_no=${data.queue_no}`)
  } catch (e: any) {
    showToast(e.response?.data?.message || '取号失败')
  } finally {
    submitting.value = false
  }
}
</script>
