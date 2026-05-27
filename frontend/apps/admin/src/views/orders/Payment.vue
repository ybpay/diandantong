<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">代收款订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNo" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="待收款" value="pending" />
            <el-option label="已收款" value="collected" />
            <el-option label="已退款" value="refunded" />
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
        <el-table-column prop="relatedOrderNo" label="关联订单" width="170" />
        <el-table-column prop="amount" label="收款金额" width="120">
          <template #default="{ row }">&yen;{{ row.amount }}</template>
        </el-table-column>
        <el-table-column prop="payMethod" label="支付方式" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="operatorName" label="操作人" width="100" />
        <el-table-column prop="remark" label="备注" min-width="150" />
        <el-table-column prop="createdAt" label="创建时间" width="160" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/orders/${row.id}`)">详情</el-button>
            <el-button v-if="row.status === 'pending'" text type="success" size="small" @click="handleCollect(row)">确认收款</el-button>
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
import { ElMessage } from 'element-plus'

const loading = ref(false)

const searchForm = reactive({ orderNo: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 2 })

const orders = ref([
  { id: 1, orderNo: 'DK20260527001', relatedOrderNo: 'DD20260526015', amount: '88.00', payMethod: '现金', status: 'pending', statusText: '待收款', operatorName: '收银员A', remark: '线下补单', createdAt: '2026-05-27 10:00' },
  { id: 2, orderNo: 'DK20260527002', relatedOrderNo: 'DD20260526020', amount: '156.00', payMethod: '微信', status: 'collected', statusText: '已收款', operatorName: '收银员B', remark: '', createdAt: '2026-05-26 18:30' },
])

const statusTag = (s: string) => ({ pending: 'warning', collected: 'success', refunded: 'info' }[s] ?? '')

const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.orderNo = ''; searchForm.status = ''; handleSearch() }
const handleCollect = (row: any) => { ElMessage.success(`已确认收款：${row.orderNo}`) }
</script>
