<template>
  <div class="p-6 space-y-4">
    <h2 class="text-lg font-semibold">订单管理</h2>

    <el-tabs v-model="activeTab" type="border-card" @tab-change="handleTabChange">
      <el-tab-pane label="全部订单" name="all" />
      <el-tab-pane label="堂食" name="eat_in_hall" />
      <el-tab-pane label="外卖" name="delivery" />
      <el-tab-pane label="快餐" name="fast_food" />
      <el-tab-pane label="团购" name="groupon" />
      <el-tab-pane label="预约" name="reservation" />
      <el-tab-pane label="充值" name="recharge" />
      <el-tab-pane label="代收款" name="payment" />
    </el-tabs>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.order_no" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable>
            <el-option label="待确认" value="pending" />
            <el-option label="已确认" value="confirmed" />
            <el-option label="已完成" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker v-model="searchForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="orders" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="order_no" label="订单号" width="170" />
        <el-table-column label="类型" width="80">
          <template #default="{ row }">
            <el-tag size="small">{{ orderTypeLabel(row.order_type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="金额" width="100">
          <template #default="{ row }">&yen;{{ row.total_amount }}</template>
        </el-table-column>
        <el-table-column label="支付方式" width="100">
          <template #default="{ row }">{{ payMethodLabel(row) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="客户" width="100">
          <template #default="{ row }">{{ row.customer_name || '-' }}</template>
        </el-table-column>
        <el-table-column label="下单时间" width="160">
          <template #default="{ row }">{{ formatTime(row.placed_at || row.created_at) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/orders/${row.id}`)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="flex justify-end mt-4">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.per_page"
          :total="pagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @current-change="fetchOrders"
          @size-change="fetchOrders"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { orderApi } from '@diandantong/admin-api'
import type { AdminOrder, OrderType } from '@diandantong/admin-types'
import { statusTagType, statusText, formatTime } from '@/composables/useOrderHelpers'

const loading = ref(false)
const activeTab = ref('all')
const orders = ref<AdminOrder[]>([])
const searchForm = reactive<{ order_no: string; status: string; dateRange: string[] | null }>({
  order_no: '',
  status: '',
  dateRange: null,
})
const pagination = reactive({ page: 1, per_page: 10, total: 0 })

const orderTypeLabel = (t: OrderType) => {
  const map: Record<OrderType, string> = {
    eat_in_hall: '堂食', delivery: '外卖', fast_food: '快餐',
    groupon: '团购', reservation: '预约', recharge: '充值', payment: '代收款',
  }
  return map[t] ?? t
}

const payMethodLabel = (row: AdminOrder) => {
  if (row.pay_items?.length) {
    const methods = row.pay_items.map(p => {
      const map: Record<string, string> = { cash: '现金', wechat: '微信', alipay: '支付宝', card: '银行卡' }
      return map[p.payment_method] ?? p.payment_method
    })
    return methods.join(', ')
  }
  return '-'
}

async function fetchOrders() {
  loading.value = true
  try {
    const q: Record<string, unknown> = {}
    if (activeTab.value !== 'all') q.order_type_eq = activeTab.value
    if (searchForm.status) q.status_eq = searchForm.status
    if (searchForm.order_no) q.order_no_cont = searchForm.order_no
    if (searchForm.dateRange?.length === 2) {
      q.placed_at_gteq = searchForm.dateRange[0]
      q.placed_at_lteq = searchForm.dateRange[1]
    }

    const { data } = await orderApi.list({ page: pagination.page, per_page: pagination.per_page, q })
    orders.value = data.data
    pagination.total = data.total
  } catch (e: any) {
    ElMessage.error(e.message || '获取订单失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchOrders()
}

const handleTabChange = () => {
  pagination.page = 1
  fetchOrders()
}

const handleReset = () => {
  searchForm.order_no = ''
  searchForm.status = ''
  searchForm.dateRange = null
  fetchOrders()
}

onMounted(fetchOrders)
</script>
