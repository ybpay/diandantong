<template>
  <div class="p-6 space-y-4">
    <h2 class="text-lg font-semibold">财务统计</h2>

    <el-card shadow="never">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="时间范围">
          <el-date-picker v-model="filterForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" />
        </el-form-item>
        <el-form-item label="门店">
          <el-select v-model="filterForm.branchId" placeholder="全部门店" clearable>
            <el-option label="总店" :value="1" />
            <el-option label="城西分店" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleExport">导出</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">总收入</p>
          <p class="text-2xl font-bold text-green-600 mt-1">&yen;186,200</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">总支出</p>
          <p class="text-2xl font-bold text-red-600 mt-1">&yen;92,400</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">净利润</p>
          <p class="text-2xl font-bold text-blue-600 mt-1">&yen;93,800</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">利润率</p>
          <p class="text-2xl font-bold text-purple-600 mt-1">50.4%</p>
        </div>
      </el-card>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <el-card shadow="hover">
        <template #header><span class="font-semibold">收支趋势</span></template>
        <div ref="revenueChartRef" class="h-72 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 收支柱状图</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header><span class="font-semibold">支付方式分布</span></template>
        <div ref="paymentChartRef" class="h-72 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 支付方式饼图</p>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const revenueChartRef = ref<HTMLElement>()
const paymentChartRef = ref<HTMLElement>()

const filterForm = reactive({ dateRange: null as any, branchId: undefined as number | undefined })

const handleQuery = () => { ElMessage.info('查询中...') }
const handleExport = () => { ElMessage.success('导出中...') }
onMounted(() => { /* TODO: ECharts */ })
</script>
