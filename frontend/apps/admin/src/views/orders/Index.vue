<template>
  <div class="p-6 space-y-4">
    <h2 class="text-lg font-semibold">订单管理</h2>

    <!-- Tabs for order types -->
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

    <!-- Search -->
    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNo" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable>
            <el-option label="待支付" value="pending" />
            <el-option label="进行中" value="processing" />
            <el-option label="已完成" value="completed" />
            <el-option label="已取消" value="cancelled" />
            <el-option label="已退款" value="refunded" />
          </el-select>
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker v-model="searchForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" />
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
        <el-table-column prop="type" label="类型" width="80">
          <template #default="{ row }">
            <el-tag size="small">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="branchName" label="门店" width="120" />
        <el-table-column prop="amount" label="金额" width="100">
          <template #default="{ row }">&yen;{{ row.amount }}</template>
        </el-table-column>
        <el-table-column prop="payMethod" label="支付方式" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="customerName" label="客户" width="100" />
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
const activeTab = ref('all')

const searchForm = reactive({
  orderNo: '',
  status: '',
  dateRange: null as any,
})

const pagination = reactive({ page: 1, pageSize: 10, total: 5 })

const orders = ref([
  { id: 1, orderNo: 'DD20260527001', type: '堂食', branchName: '总店', amount: '128.00', payMethod: '微信', status: 'completed', statusText: '已完成', customerName: '张三', createdAt: '2026-05-27 10:30' },
  { id: 2, orderNo: 'DD20260527002', type: '外卖', branchName: '总店', amount: '56.00', payMethod: '支付宝', status: 'processing', statusText: '配送中', customerName: '李四', createdAt: '2026-05-27 10:25' },
  { id: 3, orderNo: 'DD20260527003', type: '快餐', branchName: '城西店', amount: '35.00', payMethod: '微信', status: 'completed', statusText: '已完成', customerName: '王五', createdAt: '2026-05-27 10:20' },
  { id: 4, orderNo: 'DD20260527004', type: '团购', branchName: '总店', amount: '99.00', payMethod: '团购券', status: 'pending', statusText: '待使用', customerName: '赵六', createdAt: '2026-05-27 10:15' },
  { id: 5, orderNo: 'DD20260527005', type: '堂食', branchName: '总店', amount: '210.00', payMethod: '微信', status: 'processing', statusText: '进行中', customerName: '孙七', createdAt: '2026-05-27 10:10' },
])

const statusTagType = (status: string) => {
  const map: Record<string, string> = { pending: 'info', processing: 'warning', completed: 'success', cancelled: 'danger', refunded: 'info' }
  return map[status] ?? ''
}

const handleTabChange = () => { pagination.page = 1; handleSearch() }
const handleSearch = () => { /* TODO: call orders API */ }
const handleReset = () => { searchForm.orderNo = ''; searchForm.status = ''; searchForm.dateRange = null; handleSearch() }
</script>
