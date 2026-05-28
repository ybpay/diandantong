<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">外卖订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.order_no" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="配送状态">
          <el-select v-model="searchForm.delivery_status" placeholder="全部" clearable>
            <el-option label="待接单" value="pending" />
            <el-option label="备餐中" value="confirmed" />
            <el-option label="配送中" value="delivering" />
            <el-option label="已送达" value="completed" />
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
        <el-table-column label="客户" width="80">
          <template #default="{ row }">{{ row.customer_name || '-' }}</template>
        </el-table-column>
        <el-table-column label="电话" width="120">
          <template #default="{ row }">{{ row.customer_phone || '-' }}</template>
        </el-table-column>
        <el-table-column prop="delivery_address" label="配送地址" min-width="200" show-overflow-tooltip />
        <el-table-column label="金额" width="100">
          <template #default="{ row }">&yen;{{ row.total_amount }}</template>
        </el-table-column>
        <el-table-column label="配送状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="骑手" width="80">
          <template #default="{ row }">{{ row.delivery_man_name || '待分配' }}</template>
        </el-table-column>
        <el-table-column label="下单时间" width="160">
          <template #default="{ row }">{{ formatTime(row.placed_at || row.created_at) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/orders/${row.id}`)">详情</el-button>
            <el-button v-if="row.status === 'pending'" text type="success" size="small" @click="handleConfirm(row)">接单</el-button>
            <el-button v-if="row.status === 'confirmed' && !row.delivery_man_id" text type="primary" size="small" @click="handleAssign(row)">分配骑手</el-button>
            <el-button v-if="row.status === 'confirmed' && row.delivery_man_id" text type="warning" size="small" @click="handleStart(row)">开始配送</el-button>
            <el-button v-if="row.status === 'cancelled'" text disabled size="small">已取消</el-button>
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

    <el-dialog v-model="assignDialogVisible" title="分配骑手" width="400px">
      <el-form :model="assignForm">
        <el-form-item label="骑手ID">
          <el-input v-model.number="assignForm.deliveryManId" placeholder="输入骑手ID" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="assignDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmAssign" :loading="assigning">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { orderApi } from '@diandantong/admin-api'
import type { AdminOrder } from '@diandantong/admin-types'
import { statusTagType, statusText, formatTime } from '@/composables/useOrderHelpers'

const loading = ref(false)
const orders = ref<AdminOrder[]>([])
const searchForm = reactive({ order_no: '', delivery_status: '' })
const pagination = reactive({ page: 1, per_page: 10, total: 0 })

const assignDialogVisible = ref(false)
const assigning = ref(false)
const currentOrderId = ref<number>(0)
const assignForm = reactive({ deliveryManId: 0 })

async function fetchOrders() {
  loading.value = true
  try {
    const q: Record<string, unknown> = { order_type_eq: 'delivery' }
    if (searchForm.delivery_status) q.status_eq = searchForm.delivery_status
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
  searchForm.delivery_status = ''
  pagination.page = 1
  fetchOrders()
}

async function handleConfirm(row: AdminOrder) {
  try {
    await orderApi.confirm(row.id)
    ElMessage.success('已接单')
    fetchOrders()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

function handleAssign(row: AdminOrder) {
  currentOrderId.value = row.id
  assignForm.deliveryManId = 0
  assignDialogVisible.value = true
}

async function confirmAssign() {
  if (!assignForm.deliveryManId) {
    ElMessage.warning('请输入骑手ID')
    return
  }
  assigning.value = true
  try {
    await orderApi.delivery.assign(currentOrderId.value, assignForm.deliveryManId)
    ElMessage.success('已分配骑手')
    assignDialogVisible.value = false
    fetchOrders()
  } catch (e: any) {
    ElMessage.error(e.message || '分配失败')
  } finally {
    assigning.value = false
  }
}

async function handleStart(row: AdminOrder) {
  try {
    await orderApi.delivery.start(row.id)
    ElMessage.success('已开始配送')
    fetchOrders()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

onMounted(fetchOrders)
</script>
