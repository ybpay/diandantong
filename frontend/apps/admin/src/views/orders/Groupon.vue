<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">团购订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.order_no" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="券码">
          <el-input v-model="searchForm.groupon_code" placeholder="团购券码" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="待确认" value="pending" />
            <el-option label="已确认" value="confirmed" />
            <el-option label="已完成" value="completed" />
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
        <el-table-column prop="groupon_code" label="券码" width="140" />
        <el-table-column label="平台" width="100">
          <template #default="{ row }">
            <el-tag size="small" :type="row.groupon_platform === '美团' ? 'warning' : 'success'">{{ row.groupon_platform || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="团购内容" min-width="200">
          <template #default="{ row }">{{ formatLineItems(row.line_items) }}</template>
        </el-table-column>
        <el-table-column label="金额" width="100">
          <template #default="{ row }">&yen;{{ row.total_amount }}</template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="下单时间" width="160">
          <template #default="{ row }">{{ formatTime(row.placed_at || row.created_at) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/orders/${row.id}`)">详情</el-button>
            <el-button v-if="row.status === 'pending'" text type="success" size="small" @click="handleConfirm(row)">核销</el-button>
            <el-button v-if="row.status === 'confirmed'" text type="warning" size="small" @click="handleComplete(row)">完成</el-button>
            <el-button v-if="['pending', 'confirmed'].includes(row.status)" text type="danger" size="small" @click="handleCancel(row)">取消</el-button>
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { orderApi } from '@diandantong/admin-api'
import type { AdminOrder } from '@diandantong/admin-types'
import { statusTagType, statusText, formatTime, formatLineItems } from '@/composables/useOrderHelpers'

const loading = ref(false)
const orders = ref<AdminOrder[]>([])
const searchForm = reactive({ order_no: '', groupon_code: '', status: '' })
const pagination = reactive({ page: 1, per_page: 10, total: 0 })

async function fetchOrders() {
  loading.value = true
  try {
    const q: Record<string, unknown> = { order_type_eq: 'groupon' }
    if (searchForm.status) q.status_eq = searchForm.status
    if (searchForm.order_no) q.order_no_cont = searchForm.order_no
    if (searchForm.groupon_code) q.groupon_code_cont = searchForm.groupon_code

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
  searchForm.groupon_code = ''
  searchForm.status = ''
  pagination.page = 1
  fetchOrders()
}

async function handleConfirm(row: AdminOrder) {
  try {
    await orderApi.confirm(row.id)
    ElMessage.success(`团购券「${row.groupon_code || row.order_no}」已核销`)
    fetchOrders()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

async function handleComplete(row: AdminOrder) {
  try {
    await ElMessageBox.confirm('确认完成该订单？', '提示')
    await orderApi.complete(row.id)
    ElMessage.success('订单已完成')
    fetchOrders()
  } catch { /* cancelled */ }
}

async function handleCancel(row: AdminOrder) {
  try {
    await ElMessageBox.confirm('确认取消该订单？', '警告', { type: 'warning' })
    await orderApi.cancel(row.id)
    ElMessage.warning('订单已取消')
    fetchOrders()
  } catch { /* cancelled */ }
}

onMounted(fetchOrders)
</script>
