<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">团购订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNo" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="券码">
          <el-input v-model="searchForm.couponCode" placeholder="团购券码" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="待使用" value="pending" />
            <el-option label="已使用" value="used" />
            <el-option label="已过期" value="expired" />
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
        <el-table-column prop="couponCode" label="券码" width="140" />
        <el-table-column prop="platform" label="平台" width="100">
          <template #default="{ row }">
            <el-tag size="small" :type="row.platform === '美团' ? 'warning' : 'success'">{{ row.platform }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="团购内容" min-width="200" />
        <el-table-column prop="amount" label="金额" width="100">
          <template #default="{ row }">&yen;{{ row.amount }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="customerName" label="客户" width="80" />
        <el-table-column prop="usedAt" label="核销时间" width="160" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/orders/${row.id}`)">详情</el-button>
            <el-button v-if="row.status === 'pending'" text type="success" size="small" @click="handleVerify(row)">核销</el-button>
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

const searchForm = reactive({ orderNo: '', couponCode: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const orders = ref([
  { id: 1, orderNo: 'TG20260527001', couponCode: 'MT-88991234', platform: '美团', title: '双人超值套餐', amount: '99.00', status: 'pending', statusText: '待使用', customerName: '赵六', usedAt: '' },
  { id: 2, orderNo: 'TG20260527002', couponCode: 'DP-66775566', platform: '大众点评', title: '四人欢聚套餐', amount: '168.00', status: 'used', statusText: '已使用', customerName: '钱七', usedAt: '2026-05-27 12:00' },
  { id: 3, orderNo: 'TG20260527003', couponCode: 'MT-44553322', platform: '美团', title: '单人简餐', amount: '29.90', status: 'expired', statusText: '已过期', customerName: '孙八', usedAt: '' },
])

const statusTag = (s: string) => ({ pending: 'info', used: 'success', expired: 'danger', refunded: 'warning' }[s] ?? '')

const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.orderNo = ''; searchForm.couponCode = ''; searchForm.status = ''; handleSearch() }
const handleVerify = (row: any) => { ElMessage.success(`团购券「${row.couponCode}」已核销`) }
</script>
