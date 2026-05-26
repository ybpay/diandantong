<template>
  <div class="min-h-screen flex flex-col bg-gray-100">
    <header class="flex items-center justify-between bg-blue-600 text-white px-6 py-3 shadow-md">
      <div class="flex items-center gap-4">
        <el-button text class="text-white" @click="goBack">
          <el-icon class="mr-1"><arrow-left /></el-icon> 返回列表
        </el-button>
        <h1 class="text-lg font-bold">会员详情</h1>
      </div>
      <div class="flex items-center gap-4">
        <el-dropdown @command="handleCommand">
          <span class="cursor-pointer text-white">
            {{ authStore.userName }} <el-icon class="ml-1"><arrow-down /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>

    <main class="flex-1 p-6">
      <div v-loading="loading" class="space-y-6">
        <!-- VIP Info Card -->
        <div v-if="vipInfo" class="bg-white rounded-lg shadow p-6">
          <div class="flex items-start gap-6">
            <div class="flex-shrink-0 w-16 h-16 rounded-full bg-blue-100 flex items-center justify-center">
              <span class="text-2xl font-bold text-blue-600">{{ vipInfo.name?.charAt(0) || '?' }}</span>
            </div>
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-4">
                <h2 class="text-xl font-bold">{{ vipInfo.name }}</h2>
                <el-tag :type="getLevelTagType(vipInfo.level)">{{ vipInfo.level_name }}</el-tag>
              </div>
              <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div class="text-sm">
                  <span class="text-gray-500">卡号</span>
                  <p class="font-medium mt-1">{{ vipInfo.card_no }}</p>
                </div>
                <div class="text-sm">
                  <span class="text-gray-500">手机号</span>
                  <p class="font-medium mt-1">{{ vipInfo.phone }}</p>
                </div>
                <div class="text-sm">
                  <span class="text-gray-500">余额</span>
                  <p class="font-medium mt-1 text-green-600">{{ formatPrice(vipInfo.balance) }}</p>
                </div>
                <div class="text-sm">
                  <span class="text-gray-500">积分</span>
                  <p class="font-medium mt-1">{{ vipInfo.credits }}</p>
                </div>
                <div class="text-sm">
                  <span class="text-gray-500">折扣率</span>
                  <p class="font-medium mt-1">
                    {{ vipInfo.discount_rate > 0 ? `${(vipInfo.discount_rate * 100).toFixed(0)}%` : '无折扣' }}
                  </p>
                </div>
                <div class="text-sm">
                  <span class="text-gray-500">等级</span>
                  <p class="font-medium mt-1">Lv.{{ vipInfo.level }} {{ vipInfo.level_name }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recharge History -->
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-lg font-bold mb-4">充值记录</h3>
          <el-table :data="rechargeHistory" stripe v-loading="rechargeLoading">
            <el-table-column label="时间" width="180">
              <template #default="{ row }">{{ formatDate(row.created_at) }}</template>
            </el-table-column>
            <el-table-column label="充值金额" width="120" align="right">
              <template #default="{ row }">
                <span class="text-green-600 font-medium">+{{ formatPrice(row.amount) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="赠送金额" width="120" align="right">
              <template #default="{ row }">
                <span v-if="row.gift_amount > 0" class="text-orange-500 font-medium">
                  +{{ formatPrice(row.gift_amount) }}
                </span>
                <span v-else class="text-gray-400">-</span>
              </template>
            </el-table-column>
            <el-table-column label="支付方式" width="120">
              <template #default="{ row }">{{ getPaymentMethodLabel(row.payment_method) }}</template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="200" show-overflow-tooltip>
              <template #default="{ row }">{{ row.remark || '-' }}</template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!rechargeLoading && rechargeHistory.length === 0" description="暂无充值记录" />
        </div>

        <!-- Order History -->
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-lg font-bold mb-4">消费记录</h3>
          <el-table :data="orderHistory" stripe v-loading="orderLoading">
            <el-table-column prop="order_no" label="订单号" width="180" />
            <el-table-column label="订单类型" width="100">
              <template #default="{ row }">{{ getOrderTypeLabel(row.order_type) }}</template>
            </el-table-column>
            <el-table-column label="金额" width="120" align="right">
              <template #default="{ row }">
                <span class="font-medium">{{ formatPrice(row.total_price) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="getStatusTagType(row.status)" size="small">
                  {{ getStatusLabel(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="时间" width="180">
              <template #default="{ row }">{{ formatDate(row.created_at) }}</template>
            </el-table-column>
            <el-table-column prop="note" label="备注" min-width="200" show-overflow-tooltip>
              <template #default="{ row }">{{ row.note || '-' }}</template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!orderLoading && orderHistory.length === 0" description="暂无消费记录" />
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft, ArrowDown } from '@element-plus/icons-vue'
import { useAuthStore } from '@webpos/stores'
import { vipInfoApi, client } from '@webpos/api'
import { formatPrice, formatDate } from '@webpos/composables'
import type { VipInfo, Order } from '@webpos/types'

interface RechargeRecord {
  id: number
  amount: number
  gift_amount: number
  payment_method: string
  remark?: string
  created_at: string
}

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const vipInfo = ref<VipInfo | null>(null)
const rechargeHistory = ref<RechargeRecord[]>([])
const orderHistory = ref<Order[]>([])
const loading = ref(false)
const rechargeLoading = ref(false)
const orderLoading = ref(false)

const branchId = Number(route.params.branchId)
const vipInfoId = Number(route.params.vipInfoId)

onMounted(async () => {
  await fetchVipInfo()
  await Promise.all([fetchRechargeHistory(), fetchOrderHistory()])
})

async function fetchVipInfo() {
  loading.value = true
  try {
    const { data } = await vipInfoApi.get(vipInfoId)
    vipInfo.value = data
  } catch {
    ElMessage.error('加载会员信息失败')
  } finally {
    loading.value = false
  }
}

async function fetchRechargeHistory() {
  rechargeLoading.value = true
  try {
    const { data } = await client.get<RechargeRecord[]>(
      `/branches/${branchId}/vip_infos/${vipInfoId}/recharges`,
    )
    rechargeHistory.value = data
  } catch {
    rechargeHistory.value = []
  } finally {
    rechargeLoading.value = false
  }
}

async function fetchOrderHistory() {
  orderLoading.value = true
  try {
    const { data } = await client.get<Order[]>(
      `/branches/${branchId}/vip_infos/${vipInfoId}/orders`,
    )
    orderHistory.value = data
  } catch {
    orderHistory.value = []
  } finally {
    orderLoading.value = false
  }
}

function getLevelTagType(level: number): 'primary' | 'success' | 'warning' | 'danger' | 'info' {
  if (level >= 4) return 'danger'
  if (level >= 3) return 'warning'
  if (level >= 2) return 'primary'
  return 'info'
}

function getPaymentMethodLabel(method: string): string {
  const labels: Record<string, string> = {
    cash: '现金',
    wechat: '微信',
    alipay: '支付宝',
    card: '银行卡',
  }
  return labels[method] || method
}

function getOrderTypeLabel(type: string): string {
  const labels: Record<string, string> = {
    eat_in_hall: '堂食',
    fast_food: '快餐',
    delivery: '外卖',
    reservation: '预约',
    payment: '买单',
    groupon: '团购',
    recharge: '充值',
  }
  return labels[type] || type
}

function getStatusLabel(status: string): string {
  const labels: Record<string, string> = {
    pending: '待处理',
    confirmed: '已确认',
    completed: '已完成',
    cancelled: '已取消',
  }
  return labels[status] || status
}

function getStatusTagType(status: string): 'primary' | 'success' | 'warning' | 'info' | 'danger' {
  const types: Record<string, 'primary' | 'success' | 'warning' | 'info' | 'danger'> = {
    pending: 'warning',
    confirmed: 'primary',
    completed: 'success',
    cancelled: 'info',
  }
  return types[status] || 'info'
}

function goBack() {
  router.push({ name: 'users', params: { branchId } })
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'login' })
    }).catch(() => {})
  }
}
</script>
