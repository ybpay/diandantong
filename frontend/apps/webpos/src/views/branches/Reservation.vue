<template>
  <PosLayout
    title="收银台 - 预约"
    :branch-name="authStore.currentBranch?.name"
    :branch-id="branchId"
    :user-name="authStore.userName"
    @command="handleCommand"
  >
    <div class="p-6">
      <h3 class="text-lg font-bold mb-4">预约管理</h3>
      <el-table :data="orders" stripe>
        <el-table-column prop="order_no" label="订单号" width="180" />
        <el-table-column label="预约信息">
          <template #default="{ row }">
            {{ row.reservation_info?.name }} · {{ row.reservation_info?.guest_num }}人
          </template>
        </el-table-column>
        <el-table-column label="预约时间">
          <template #default="{ row }">{{ formatDate(row.reservation_info?.reserved_at || '') }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="confirmReservation(row)">确认</el-button>
            <el-button size="small" @click="bindTable(row)">绑定桌台</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore, useOrderStore } from '@webpos/stores'
import { formatDate } from '@webpos/composables'
import type { Order } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const orderStore = useOrderStore()

const branchId = computed(() => Number(route.params.branchId))
const orders = computed(() => orderStore.orders)

function statusText(status: string) {
  return { pending: '待确认', confirmed: '已确认', completed: '已完成', cancelled: '已取消' }[status] || status
}
function statusType(status: string) {
  return { pending: 'warning', confirmed: 'success', completed: 'info', cancelled: 'danger' }[status] as 'warning' | 'success' | 'info' | 'danger'
}

async function confirmReservation(order: Order) {
  try {
    await orderStore.confirmOrder(branchId.value, 'reservation', order.id)
    ElMessage.success('已确认')
  } catch {
    ElMessage.error('操作失败')
  }
}

function bindTable(order: Order) {
  // TODO: Open table selection dialog
  ElMessage.info('绑定桌台功能开发中')
}

async function fetchOrders() {
  await orderStore.fetchOrders(branchId.value, 'reservation')
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}

onMounted(fetchOrders)
</script>
