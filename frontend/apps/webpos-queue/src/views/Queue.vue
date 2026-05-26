<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
        <div class="flex items-center gap-4">
          <el-button text @click="goBack">
            &larr; 返回门店
          </el-button>
          <h1 class="text-xl font-semibold text-gray-800">排队管理</h1>
        </div>
        <div class="flex items-center gap-6">
          <div class="text-sm text-gray-600">
            <span>当前等待: <strong class="text-orange-600">{{ waitingCount }}</strong> 组</span>
          </div>
          <span class="text-sm text-gray-600">{{ authStore.username }}</span>
        </div>
      </div>
    </header>

    <main class="max-w-7xl mx-auto px-4 py-6">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Add New Queue Entry Form -->
        <div class="lg:col-span-1">
          <el-card shadow="never">
            <template #header>
              <span class="font-semibold text-gray-800">新增排队</span>
            </template>
            <el-form
              ref="formRef"
              :model="newEntry"
              :rules="formRules"
              label-position="top"
              @submit.prevent="handleAddEntry"
            >
              <el-form-item label="姓名" prop="name">
                <el-input
                  v-model="newEntry.name"
                  placeholder="请输入顾客姓名"
                  clearable
                />
              </el-form-item>

              <el-form-item label="手机号" prop="phone">
                <el-input
                  v-model="newEntry.phone"
                  placeholder="请输入手机号"
                  clearable
                />
              </el-form-item>

              <el-form-item label="用餐人数" prop="guest_num">
                <el-input-number
                  v-model="newEntry.guest_num"
                  :min="1"
                  :max="99"
                  controls-position="right"
                  class="w-full"
                />
              </el-form-item>

              <el-form-item>
                <el-button
                  type="primary"
                  class="w-full"
                  :loading="submitting"
                  @click="handleAddEntry"
                >
                  取号排队
                </el-button>
              </el-form-item>
            </el-form>
          </el-card>
        </div>

        <!-- Queue Board -->
        <div class="lg:col-span-2">
          <QueueBoard
            :entries="queueEntries"
            :loading="loadingQueue"
            @call="handleCall"
            @seat="handleSeat"
            @cancel="handleCancel"
          />
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElCard, ElForm, ElFormItem, ElInput, ElInputNumber, ElButton, ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { QueueBoard } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { queueApi } from '@webpos/api'
import type { QueueEntry } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const branchId = computed(() => route.params.branchId as string)

// Queue entries
const queueEntries = ref<QueueEntry[]>([])
const loadingQueue = ref(false)
const submitting = ref(false)

// New entry form
const formRef = ref<FormInstance>()
const newEntry = reactive({
  name: '',
  phone: '',
  guest_num: 2,
})

const formRules: FormRules = {
  name: [
    { required: true, message: '请输入顾客姓名', trigger: 'blur' },
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' },
  ],
  guest_num: [
    { required: true, message: '请输入用餐人数', trigger: 'change' },
  ],
}

// Computed
const waitingCount = computed(() =>
  queueEntries.value.filter((e) => e.status === 'waiting').length
)

// Polling
let pollTimer: ReturnType<typeof setInterval> | null = null

async function fetchQueue() {
  loadingQueue.value = true
  try {
    queueEntries.value = await queueApi.list(branchId.value)
  } catch (error) {
    console.error('Failed to fetch queue:', error)
    ElMessage.error('获取排队列表失败')
  } finally {
    loadingQueue.value = false
  }
}

function startPolling() {
  pollTimer = setInterval(fetchQueue, 15000) // refresh every 15s
}

function stopPolling() {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
}

// Actions
async function handleAddEntry() {
  if (!formRef.value) return

  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    await queueApi.create(branchId.value, {
      name: newEntry.name,
      phone: newEntry.phone || undefined,
      guest_num: newEntry.guest_num,
    })
    ElMessage.success('取号成功')

    // Reset form
    newEntry.name = ''
    newEntry.phone = ''
    newEntry.guest_num = 2
    formRef.value.resetFields()

    await fetchQueue()
  } catch (error) {
    console.error('Failed to add queue entry:', error)
    ElMessage.error('取号失败，请重试')
  } finally {
    submitting.value = false
  }
}

async function handleCall(entry: QueueEntry) {
  try {
    await queueApi.call(branchId.value, entry.id)
    ElMessage.success(`正在呼叫 ${entry.name} (排队号: ${entry.queue_number})`)
    await fetchQueue()
  } catch (error) {
    console.error('Failed to call:', error)
    ElMessage.error('呼叫失败')
  }
}

async function handleSeat(entry: QueueEntry) {
  try {
    await ElMessageBox.confirm(
      `确认安排 ${entry.name} (排队号: ${entry.queue_number}) 入座？`,
      '确认入座',
      { confirmButtonText: '确认', cancelButtonText: '取消', type: 'info' }
    )
    await queueApi.seat(branchId.value, entry.id)
    ElMessage.success(`${entry.name} 已入座`)
    await fetchQueue()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Failed to seat:', error)
      ElMessage.error('入座操作失败')
    }
  }
}

async function handleCancel(entry: QueueEntry) {
  try {
    await ElMessageBox.confirm(
      `确认取消 ${entry.name} (排队号: ${entry.queue_number}) 的排队？`,
      '取消排队',
      { confirmButtonText: '确认取消', cancelButtonText: '保留', type: 'warning' }
    )
    await queueApi.cancel(branchId.value, entry.id)
    ElMessage.success(`已取消 ${entry.name} 的排队`)
    await fetchQueue()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Failed to cancel:', error)
      ElMessage.error('取消操作失败')
    }
  }
}

function goBack() {
  router.push({ name: 'Shop' })
}

// Lifecycle
onMounted(() => {
  fetchQueue()
  startPolling()
})

onUnmounted(() => {
  stopPolling()
})
</script>
