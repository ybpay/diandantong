<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">代收款订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.order_no" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="待收款" value="pending" />
            <el-option label="已收款" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
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
        <el-table-column label="关联订单" width="170">
          <template #default="{ row }">{{ row.related_order_no || '-' }}</template>
        </el-table-column>
        <el-table-column label="收款金额" width="120">
          <template #default="{ row }">&yen;{{ row.total_amount }}</template>
        </el-table-column>
        <el-table-column label="支付方式" width="100">
          <template #default="{ row }">{{ payMethodText(row.payment_method) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作人" width="100">
          <template #default="{ row }">{{ row.operator_name || '-' }}</template>
        </el-table-column>
        <el-table-column prop="note" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="创建时间" width="160">
          <template #default="{ row }">{{ formatTime(row.placed_at || row.created_at) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/orders/${row.id}`)">详情</el-button>
            <el-button v-if="row.status === 'pending'" text type="success" size="small" @click="handleConfirm(row)">确认收款</el-button>
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
import type { AdminOrder, PaymentMethod } from '@diandantong/admin-types'
import { statusTagType, statusText, formatTime } from '@/composables/useOrderHelpers'

const loading = ref(false)
const orders = ref<AdminOrder[]>([])
const searchForm = reactive({ order_no: '', status: '' })
const pagination = reactive({ page: 1, per_page: 10, total: 0 })

const payMethodText = (m?: PaymentMethod | string) => {
  const map: Record<string, string> = { cash: '现金', wechat: '微信', alipay: '支付宝', card: '银行卡', vip_balance: '会员余额', mixed: '混合' }
  return map[m ?? ''] ?? m ?? '-'
}

async function fetchOrders() {
  loading.value = true
  try {
    const q: Record<string, unknown> = { order_type_eq: 'payment' }
    if (searchForm.status) q.status_eq = searchForm.status
    if (searchForm.order_no) q.order_no_cont = searchForm.order_no

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

const handleReset = () => {
  searchForm.order_no = ''
  searchForm.status = ''
  pagination.page = 1
  fetchOrders()
}

async function handleConfirm(row: AdminOrder) {
  try {
    await orderApi.complete(row.id)
    ElMessage.success(`已确认收款：${row.order_no}`)
    fetchOrders()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

onMounted(fetchOrders)
</script>
