<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">充值订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNo" placeholder="搜索订单号" clearable />
        </el-form-item>
        <el-form-item label="会员">
          <el-input v-model="searchForm.memberKeyword" placeholder="手机号/姓名" clearable />
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
        <el-table-column prop="memberName" label="会员" width="100" />
        <el-table-column prop="memberPhone" label="手机号" width="120" />
        <el-table-column prop="productName" label="充值产品" min-width="200" />
        <el-table-column prop="payAmount" label="支付金额" width="100">
          <template #default="{ row }">&yen;{{ row.payAmount }}</template>
        </el-table-column>
        <el-table-column prop="giftAmount" label="赠送金额" width="100">
          <template #default="{ row }"><span class="text-red-500">+&yen;{{ row.giftAmount }}</span></template>
        </el-table-column>
        <el-table-column prop="totalAmount" label="到账金额" width="100">
          <template #default="{ row }">&yen;{{ row.totalAmount }}</template>
        </el-table-column>
        <el-table-column prop="payMethod" label="支付方式" width="100" />
        <el-table-column prop="createdAt" label="充值时间" width="160" />
        <el-table-column label="操作" width="100" fixed="right">
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

const searchForm = reactive({ orderNo: '', memberKeyword: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const orders = ref([
  { id: 1, orderNo: 'CZ20260527001', memberName: '王会员', memberPhone: '138****5555', productName: '充500送50', payAmount: '500.00', giftAmount: '50.00', totalAmount: '550.00', payMethod: '微信', createdAt: '2026-05-27 09:30' },
  { id: 2, orderNo: 'CZ20260527002', memberName: '李会员', memberPhone: '139****6666', productName: '充1000送150', payAmount: '1000.00', giftAmount: '150.00', totalAmount: '1150.00', payMethod: '支付宝', createdAt: '2026-05-27 10:00' },
  { id: 3, orderNo: 'CZ20260527003', memberName: '张会员', memberPhone: '137****7777', productName: '充200送10', payAmount: '200.00', giftAmount: '10.00', totalAmount: '210.00', payMethod: '微信', createdAt: '2026-05-27 11:15' },
])

const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.orderNo = ''; searchForm.memberKeyword = ''; handleSearch() }
</script>
