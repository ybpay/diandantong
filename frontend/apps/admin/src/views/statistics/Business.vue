<template>
  <div class="p-6 space-y-4">
    <h2 class="text-lg font-semibold">营业统计</h2>

    <!-- Date Range Picker -->
    <el-card shadow="never">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="时间范围">
          <el-date-picker v-model="filterForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" />
        </el-form-item>
        <el-form-item label="门店">
          <el-select v-model="filterForm.branchId" placeholder="全部门店" clearable>
            <el-option label="总店" :value="1" />
            <el-option label="城西分店" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleExport">导出报表</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Stats Summary -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">总营收</p>
          <p class="text-2xl font-bold text-blue-600 mt-1">&yen;{{ summary.totalRevenue }}</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">总订单</p>
          <p class="text-2xl font-bold text-green-600 mt-1">{{ summary.totalOrders }}</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">客流量</p>
          <p class="text-2xl font-bold text-purple-600 mt-1">{{ summary.customerCount }}</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">翻台率</p>
          <p class="text-2xl font-bold text-orange-600 mt-1">{{ summary.turnoverRate }}次</p>
        </div>
      </el-card>
    </div>

    <!-- Charts -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <el-card shadow="hover">
        <template #header><span class="font-semibold">营收趋势</span></template>
        <div ref="revenueTrendRef" class="h-72 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 营收趋势折线图</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header><span class="font-semibold">订单量趋势</span></template>
        <div ref="orderTrendRef" class="h-72 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 订单量柱状图</p>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const revenueTrendRef = ref<HTMLElement>()
const orderTrendRef = ref<HTMLElement>()

const filterForm = reactive({ dateRange: null as any, branchId: undefined as number | undefined })

const summary = ref({
  totalRevenue: '186,200.00',
  totalOrders: '2,850',
  customerCount: '3,120',
  turnoverRate: '2.8',
})

const handleQuery = () => { ElMessage.info('查询数据...') }
const handleExport = () => { ElMessage.success('导出报表中...') }

onMounted(() => {
  // TODO: Initialize ECharts
})
</script>
