<template>
  <div class="p-6 space-y-4">
    <h2 class="text-lg font-semibold">订单统计</h2>

    <el-card shadow="never">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="时间范围">
          <el-date-picker v-model="filterForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" />
        </el-form-item>
        <el-form-item label="订单类型">
          <el-select v-model="filterForm.orderType" placeholder="全部" clearable>
            <el-option label="堂食" value="eat_in" />
            <el-option label="外卖" value="delivery" />
            <el-option label="快餐" value="fast_food" />
            <el-option label="团购" value="groupon" />
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
          <p class="text-sm text-gray-500">总订单</p>
          <p class="text-2xl font-bold text-blue-600 mt-1">2,850</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">已完成</p>
          <p class="text-2xl font-bold text-green-600 mt-1">2,620</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">已取消</p>
          <p class="text-2xl font-bold text-red-600 mt-1">180</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">完成率</p>
          <p class="text-2xl font-bold text-purple-600 mt-1">93.7%</p>
        </div>
      </el-card>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <el-card shadow="hover">
        <template #header><span class="font-semibold">订单量趋势</span></template>
        <div ref="orderChartRef" class="h-72 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 订单量趋势图</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header><span class="font-semibold">订单来源分布</span></template>
        <div ref="sourceChartRef" class="h-72 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 订单来源饼图</p>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const orderChartRef = ref<HTMLElement>()
const sourceChartRef = ref<HTMLElement>()

const filterForm = reactive({ dateRange: null as any, orderType: '' })

const handleQuery = () => { ElMessage.info('查询数据...') }
const handleExport = () => { ElMessage.success('导出中...') }

onMounted(() => { /* TODO: ECharts */ })
</script>
