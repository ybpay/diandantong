<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">充值订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.order_no" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="会员">
          <el-input v-model="searchForm.member_keyword" placeholder="手机号/姓名" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="待确认" value="pending" />
            <el-option label="已完成" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchOrders">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="orders" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="order_no" label="订单号" width="170" />
        <el-table-column label="会员" width="100">
          <template #default="{ row }">{{ row.vip_name || '-' }}</template>
        </el-table-column>
        <el-table-column label="手机号" width="120">
          <template #default="{ row }">{{ row.vip_phone || '-' }}</template>
        </el-table-column>
        <el-table-column label="充值金额" width="100">
          <template #default="{ row }">&yen;{{ row.recharge_amount }}</template>
        </el-table-column>
        <el-table-column label="赠送金额" width="100">
          <template #default="{ row }"><span class="text-red-500">+&yen;{{ row.bonus_amount || '0.00' }}</span></template>
        </el-table-column>
        <el-table-column label="实付金额" width="100">
          <template #default="{ row }">&yen;{{ row.total_amount }}</template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="充值时间" width="160">
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
import type { AdminOrder } from '@diandantong/admin-types'

const loading = ref(false)
const orders = ref<AdminOrder[]>([])
const searchForm = reactive({ order_no: '', member_keyword: '', status: '' })
const pagination = reactive({ page: 1, per_page: 10, total: 0 })

const statusTagType = (s: string) => {
  const map: Record<string, string> = { pending: 'info', completed: 'success', cancelled: 'danger' }
  return map[s] ?? ''
}

const statusText = (s: string) => {
  const map: Record<string, string> = { pending: '待确认', completed: '已完成', cancelled: '已取消' }
  return map[s] ?? s
}

const formatTime = (t: string) => {
  if (!t) return ''
  return new Date(t).toLocaleString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
}

async function fetchOrders() {
  loading.value = true
  try {
    const q: Record<string, unknown> = { order_type_eq: 'recharge' }
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

const handleReset = () => {
  searchForm.order_no = ''
  searchForm.member_keyword = ''
  searchForm.status = ''
  pagination.page = 1
  fetchOrders()
}

onMounted(fetchOrders)
</script>
