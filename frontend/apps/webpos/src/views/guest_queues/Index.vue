<template>
  <PosLayout title="排队管理" :branch-name="authStore.currentBranch?.name" :branch-id="branchId" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6">
      <div class="flex items-center justify-between mb-4">
        <div class="flex gap-2">
          <el-radio-group v-model="statusFilter" @change="fetchQueues">
            <el-radio-button value="">全部</el-radio-button>
            <el-radio-button value="waiting">等待中</el-radio-button>
            <el-radio-button value="called">已叫号</el-radio-button>
          </el-radio-group>
        </div>
        <el-button type="primary" @click="showCreateDialog = true">新增排队</el-button>
      </div>

      <QueueBoard :queues="filteredQueues" @call="callQueue" @seat="seatQueue" @cancel="cancelQueue" />

      <el-dialog v-model="showCreateDialog" title="新增排队" width="400px">
        <el-form :model="newQueue" label-width="80px">
          <el-form-item label="姓名"><el-input v-model="newQueue.name" /></el-form-item>
          <el-form-item label="手机号"><el-input v-model="newQueue.phone" /></el-form-item>
          <el-form-item label="人数"><el-input-number v-model="newQueue.guest_num" :min="1" /></el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="showCreateDialog = false">取消</el-button>
          <el-button type="primary" @click="createQueue">确定</el-button>
        </template>
      </el-dialog>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout, QueueBoard } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { queueApi } from '@webpos/api'
import type { GuestQueue } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const branchId = computed(() => Number(route.params.branchId))

const queues = ref<GuestQueue[]>([])
const statusFilter = ref('')
const showCreateDialog = ref(false)
const newQueue = ref({ name: '', phone: '', guest_num: 2 })

const filteredQueues = computed(() => {
  if (!statusFilter.value) return queues.value.filter((q) => q.status !== 'cancelled' && q.status !== 'seated')
  return queues.value.filter((q) => q.status === statusFilter.value)
})

async function fetchQueues() {
  try {
    const { data } = await queueApi.list(branchId.value)
    queues.value = data.data || data as unknown as GuestQueue[]
  } catch {
    ElMessage.error('加载排队列表失败')
  }
}

async function createQueue() {
  try {
    await queueApi.create(branchId.value, newQueue.value)
    ElMessage.success('创建成功')
    showCreateDialog.value = false
    newQueue.value = { name: '', phone: '', guest_num: 2 }
    await fetchQueues()
  } catch {
    ElMessage.error('创建失败')
  }
}

async function callQueue(queue: GuestQueue) {
  try {
    await queueApi.call(branchId.value, queue.id)
    ElMessage.success('已叫号')
    await fetchQueues()
  } catch {
    ElMessage.error('叫号失败')
  }
}

async function seatQueue(queue: GuestQueue) {
  try {
    await queueApi.seat(branchId.value, queue.id)
    ElMessage.success('已入座')
    await fetchQueues()
  } catch {
    ElMessage.error('入座失败')
  }
}

async function cancelQueue(queue: GuestQueue) {
  try {
    await ElMessageBox.confirm('确定取消该排队?')
    await queueApi.cancel(branchId.value, queue.id)
    ElMessage.success('已取消')
    await fetchQueues()
  } catch { /* cancelled */ }
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}

onMounted(fetchQueues)
</script>
