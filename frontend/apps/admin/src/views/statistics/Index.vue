<template>
  <div class="p-6 space-y-6">
    <h2 class="text-lg font-semibold">数据统计</h2>

    <!-- Quick Stats -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">今日订单数</p>
          <p class="text-3xl font-bold text-blue-500 mt-2">128</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">今日营收</p>
          <p class="text-3xl font-bold text-green-500 mt-2">&yen;8,650</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">本月营收</p>
          <p class="text-3xl font-bold text-purple-500 mt-2">&yen;186,200</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">平均客单价</p>
          <p class="text-3xl font-bold text-orange-500 mt-2">&yen;67.6</p>
        </div>
      </el-card>
    </div>

    <!-- Charts Placeholder -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <el-card shadow="hover">
        <template #header><span class="font-semibold">近7日营收趋势</span></template>
        <div ref="revenueChartRef" class="h-64 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 营收趋势图占位</p>
        </div>
      </el-card>

      <el-card shadow="hover">
        <template #header><span class="font-semibold">订单类型分布</span></template>
        <div ref="orderTypeChartRef" class="h-64 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 订单类型饼图占位</p>
        </div>
      </el-card>
    </div>

    <!-- Navigation Links -->
    <el-card shadow="hover">
      <template #header><span class="font-semibold">详细报表</span></template>
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        <el-button class="h-auto py-4" @click="$router.push('/statistics/business')">
          <div class="text-center">
            <p class="font-semibold">营业统计</p>
            <p class="text-xs text-gray-400 mt-1">营收、客流、翻台率</p>
          </div>
        </el-button>
        <el-button class="h-auto py-4" @click="$router.push('/statistics/orders')">
          <div class="text-center">
            <p class="font-semibold">订单统计</p>
            <p class="text-xs text-gray-400 mt-1">订单量、来源、趋势</p>
          </div>
        </el-button>
        <el-button class="h-auto py-4" @click="$router.push('/statistics/products')">
          <div class="text-center">
            <p class="font-semibold">菜品统计</p>
            <p class="text-xs text-gray-400 mt-1">销量排行、品类分析</p>
          </div>
        </el-button>
        <el-button class="h-auto py-4" @click="$router.push('/statistics/finance')">
          <div class="text-center">
            <p class="font-semibold">财务统计</p>
            <p class="text-xs text-gray-400 mt-1">收入、支出、利润</p>
          </div>
        </el-button>
        <el-button class="h-auto py-4" @click="$router.push('/statistics/coupons')">
          <div class="text-center">
            <p class="font-semibold">优惠券统计</p>
            <p class="text-xs text-gray-400 mt-1">发放、使用、转化率</p>
          </div>
        </el-button>
        <el-button class="h-auto py-4" @click="$router.push('/statistics/workers')">
          <div class="text-center">
            <p class="font-semibold">员工统计</p>
            <p class="text-xs text-gray-400 mt-1">绩效、工时、排行</p>
          </div>
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
// TODO: import * as echarts from 'echarts'
// TODO: Initialize charts in onMounted

const revenueChartRef = ref<HTMLElement>()
const orderTypeChartRef = ref<HTMLElement>()

onMounted(() => {
  // TODO: Initialize ECharts instances
  // const revenueChart = echarts.init(revenueChartRef.value!)
  // const orderTypeChart = echarts.init(orderTypeChartRef.value!)
})
</script>
