<template>
  <PosLayout title="订单列表" :branch-name="authStore.currentBranch?.name" :branch-id="branchId" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6">
      <div class="flex items-center gap-4 mb-4">
        <el-radio-group v-model="orderType" @change="fetchOrders">
          <el-radio-button value="eat_in_hall">堂食</el-radio-button>
          <el-radio-button value="fast_food">快餐</el-radio-button>
          <el-radio-button value="delivery">外卖</el-radio-button>
          <el-radio-button value="reservation">预约</el-radio-button>
        </el-radio-group>
        <el-radio-group v-model="statusFilter" @change="fetchOrders">
          <el-radio-button value="">全部</el-radio-button>
          <el-radio-button value="pending">待处理</el-radio-button>
          <el-radio-button value="confirmed">已确认</el-radio-button>
          <el-radio-button value="completed">已完成</el-radio-button>
        </el-radio-group>
      </div>

      <el-table :data="orderStore.orders" stripe v-loading="orderStore.loading">
        <el-table-column prop="order_no" label="订单号" width="180" />
        <el-table-column label="类型" width="80">
          <template #default="{ row }">{{ orderTypeLabel(row.order_type) }}</template>
        </el-table-column>
        <el-table-column label="金额" width="100">
          <template #default="{ row }">{{ formatPrice(row.total_price) }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="会员" width="100">
          <template #default="{ row }">{{ row.vip_info?.name || '-' }}</template>
        </el-table-column>
        <el-table-column label="时间" width="160">
          <template #default="{ row }">{{ formatTime(row.created_at) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="settle(row)" v-if="row.status === 'confirmed'">结算</el-button>
            <el-button size="small" @click="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore, useOrderStore } from '@webpos/stores'
import { formatPrice, formatTime } from '@webpos/composables'
import type { Order, OrderType, OrderStatus } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const orderStore = useOrderStore()

const branchId = computed(() => Number(route.params.branchId))
const orderType = ref<OrderType>('eat_in_hall')
const statusFilter = ref<OrderStatus | ''>('')

function orderTypeLabel(type: string) {
  return { eat_in_hall: '堂食', fast_food: '快餐', delivery: '外卖', reservation: '预约' }[type] || type
}

function statusLabel(status: string) {
  return { pending: '待处理', confirmed: '已确认', completed: '已完成', cancelled: '已取消' }[status] || status
}

function statusType(status: string) {
  return { pending: 'warning', confirmed: '', completed: 'success', cancelled: 'danger' }[status] as '' | 'success' | 'warning' | 'danger'
}

function settle(order: Order) {
  router.push({
    name: 'orderSettle',
    params: { branchId: branchId.value, orderId: order.id, orderType: order.order_type },
  })
}

function viewDetail(order: Order) {
  router.push({
    name: 'tableOrder',
    params: { branchId: branchId.value, tableId: order.table?.id || 0, orderId: order.id },
  })
}

async function fetchOrders() {
  await orderStore.fetchOrders(branchId.value, orderType.value, {
    status: statusFilter.value || undefined,
  } as { status?: OrderStatus })
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
