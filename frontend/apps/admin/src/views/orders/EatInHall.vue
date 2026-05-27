<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">堂食订单</h2>
    </div>

    <!-- Search -->
    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNo" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="桌号">
          <el-input v-model="searchForm.tableNo" placeholder="桌号" clearable style="width: 120px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="待支付" value="pending" />
            <el-option label="用餐中" value="dining" />
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

    <!-- Orders Table -->
    <el-card shadow="never">
      <el-table :data="orders" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="orderNo" label="订单号" width="170" />
        <el-table-column prop="tableNo" label="桌号" width="80">
          <template #default="{ row }">
            <el-tag type="warning" size="small">{{ row.tableNo }}号桌</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="personCount" label="人数" width="70" />
        <el-table-column prop="items" label="菜品明细" min-width="250">
          <template #default="{ row }">
            <span>{{ row.itemSummary }}</span>
          </template>
        </el-table-column>
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
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'

const loading = ref(false)

const searchForm = reactive({ orderNo: '', tableNo: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const orders = ref([
  { id: 1, orderNo: 'DD20260527001', tableNo: 'A3', personCount: 4, itemSummary: '宫保鸡丁 x1, 糖醋排骨 x1, 蛋炒饭 x4', amount: '188.00', status: 'dining', statusText: '用餐中', createdAt: '2026-05-27 11:30' },
  { id: 2, orderNo: 'DD20260527005', tableNo: 'B1', personCount: 6, itemSummary: '水煮鱼 x1, 麻婆豆腐 x1, 米饭 x6', amount: '210.00', status: 'dining', statusText: '用餐中', createdAt: '2026-05-27 11:10' },
  { id: 3, orderNo: 'DD20260527008', tableNo: 'C5', personCount: 2, itemSummary: '西红柿鸡蛋 x1, 蛋炒饭 x2', amount: '56.00', status: 'completed', statusText: '已完成', createdAt: '2026-05-27 10:30' },
])

const statusTag = (s: string) => ({ pending: 'info', dining: 'warning', completed: 'success', cancelled: 'danger' }[s] ?? '')

const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.orderNo = ''; searchForm.tableNo = ''; searchForm.status = ''; handleSearch() }
</script>
