<template>
  <PosLayout title="账单中心" :branch-name="authStore.currentBranch?.name" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6">
      <div class="flex items-center gap-4 mb-4">
        <el-date-picker v-model="dateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" @change="fetchBills" />
      </div>
      <el-table :data="bills" stripe>
        <el-table-column prop="date" label="日期" width="120" />
        <el-table-column prop="total_orders" label="订单数" width="80" />
        <el-table-column label="总金额" width="120">
          <template #default="{ row }">{{ formatPrice(row.total_amount) }}</template>
        </el-table-column>
        <el-table-column label="现金" width="100">
          <template #default="{ row }">{{ formatPrice(row.cash_amount) }}</template>
        </el-table-column>
        <el-table-column label="微信" width="100">
          <template #default="{ row }">{{ formatPrice(row.wechat_amount) }}</template>
        </el-table-column>
        <el-table-column label="支付宝" width="100">
          <template #default="{ row }">{{ formatPrice(row.alipay_amount) }}</template>
        </el-table-column>
        <el-table-column label="退款" width="100">
          <template #default="{ row }">{{ formatPrice(row.refund_amount) }}</template>
        </el-table-column>
      </el-table>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { billApi } from '@webpos/api'
import { formatPrice } from '@webpos/composables'
import type { BillCenter } from '@webpos/types'

const router = useRouter()
const authStore = useAuthStore()
const bills = ref<BillCenter[]>([])
const dateRange = ref<[Date, Date] | null>(null)

async function fetchBills() {
  if (!dateRange.value || !authStore.currentBranch) return
  try {
    const [start, end] = dateRange.value
    const { data } = await billApi.getBillRange(
      authStore.currentBranch.id,
      start.toISOString().split('T')[0],
      end.toISOString().split('T')[0]
    )
    bills.value = data
  } catch {
    ElMessage.error('加载账单失败')
  }
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}
</script>
