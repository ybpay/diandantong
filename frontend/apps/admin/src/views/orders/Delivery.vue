<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">外卖订单</h2>
    </div>

    <!-- Search -->
    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNo" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="配送状态">
          <el-select v-model="searchForm.deliveryStatus" placeholder="全部" clearable>
            <el-option label="待接单" value="pending" />
            <el-option label="备餐中" value="preparing" />
            <el-option label="配送中" value="delivering" />
            <el-option label="已送达" value="delivered" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Delivery Orders Table -->
    <el-card shadow="never">
      <el-table :data="orders" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="orderNo" label="订单号" width="170" />
        <el-table-column prop="customerName" label="客户" width="80" />
        <el-table-column prop="phone" label="电话" width="120" />
        <el-table-column prop="address" label="配送地址" min-width="200" show-overflow-tooltip />
        <el-table-column prop="amount" label="金额" width="100">
          <template #default="{ row }">&yen;{{ row.amount }}</template>
        </el-table-column>
        <el-table-column prop="deliveryStatus" label="配送状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.deliveryStatus)" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="riderName" label="骑手" width="80" />
        <el-table-column prop="createdAt" label="下单时间" width="160" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/orders/${row.id}`)">详情</el-button>
            <el-button v-if="row.deliveryStatus === 'pending'" text type="success" size="small" @click="handleAccept(row)">接单</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="flex justify-end mt-4">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)

const searchForm = reactive({ orderNo: '', deliveryStatus: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const orders = ref([
  { id: 1, orderNo: 'WM20260527001', customerName: '李四', phone: '138****1234', address: '杭州市西湖区文三路100号 3号楼501', amount: '56.00', deliveryStatus: 'delivering', statusText: '配送中', riderName: '王骑手', createdAt: '2026-05-27 10:25' },
  { id: 2, orderNo: 'WM20260527002', customerName: '赵五', phone: '139****5678', address: '杭州市滨江区江南大道200号', amount: '42.00', deliveryStatus: 'pending', statusText: '待接单', riderName: '', createdAt: '2026-05-27 10:35' },
  { id: 3, orderNo: 'WM20260527003', customerName: '钱六', phone: '137****9012', address: '杭州市西湖区学院路50号 2栋301', amount: '68.00', deliveryStatus: 'delivered', statusText: '已送达', riderName: '张骑手', createdAt: '2026-05-27 09:50' },
])

const statusTag = (s: string) => ({ pending: 'info', preparing: 'warning', delivering: '', delivered: 'success', cancelled: 'danger' }[s] ?? '')

const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.orderNo = ''; searchForm.deliveryStatus = ''; handleSearch() }
const handleAccept = (row: any) => { ElMessage.success(`已接单：${row.orderNo}`) }
</script>
