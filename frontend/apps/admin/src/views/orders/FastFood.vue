<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">快餐订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNo" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="取餐码">
          <el-input v-model="searchForm.pickupCode" placeholder="取餐码" clearable style="width: 120px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="待制作" value="pending" />
            <el-option label="制作中" value="preparing" />
            <el-option label="待取餐" value="ready" />
            <el-option label="已完成" value="completed" />
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
        <el-table-column prop="orderNo" label="订单号" width="170" />
        <el-table-column prop="pickupCode" label="取餐码" width="100">
          <template #default="{ row }">
            <span class="font-bold text-orange-500">{{ row.pickupCode }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="itemSummary" label="菜品" min-width="200" />
        <el-table-column prop="amount" label="金额" width="100">
          <template #default="{ row }">&yen;{{ row.amount }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="下单时间" width="160" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/orders/${row.id}`)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="flex justify-end mt-4">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'

const loading = ref(false)

const searchForm = reactive({ orderNo: '', pickupCode: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const orders = ref([
  { id: 1, orderNo: 'KS20260527001', pickupCode: 'A12', itemSummary: '宫保鸡丁盖饭 x1', amount: '22.00', status: 'ready', statusText: '待取餐', createdAt: '2026-05-27 11:45' },
  { id: 2, orderNo: 'KS20260527002', pickupCode: 'A13', itemSummary: '红烧牛肉面 x1, 卤蛋 x1', amount: '28.00', status: 'preparing', statusText: '制作中', createdAt: '2026-05-27 11:50' },
  { id: 3, orderNo: 'KS20260527003', pickupCode: 'A11', itemSummary: '蛋炒饭 x1', amount: '15.00', status: 'completed', statusText: '已完成', createdAt: '2026-05-27 11:30' },
])

const statusTag = (s: string) => ({ pending: 'info', preparing: 'warning', ready: '', completed: 'success' }[s] ?? '')

const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.orderNo = ''; searchForm.pickupCode = ''; searchForm.status = ''; handleSearch() }
</script>
