<template>
  <div class="p-6 space-y-4">
    <h2 class="text-lg font-semibold">优惠券统计</h2>

    <el-card shadow="never">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="时间范围">
          <el-date-picker v-model="filterForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">发放总量</p>
          <p class="text-2xl font-bold text-blue-600 mt-1">5,200</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">领取量</p>
          <p class="text-2xl font-bold text-green-600 mt-1">3,860</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">使用量</p>
          <p class="text-2xl font-bold text-purple-600 mt-1">2,150</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">核销率</p>
          <p class="text-2xl font-bold text-orange-600 mt-1">55.7%</p>
        </div>
      </el-card>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <el-card shadow="hover">
        <template #header><span class="font-semibold">优惠券使用趋势</span></template>
        <div ref="usageTrendRef" class="h-72 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 使用趋势折线图</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header><span class="font-semibold">各券使用情况</span></template>
        <el-table :data="couponStats" stripe style="width: 100%">
          <el-table-column prop="name" label="优惠券" min-width="150" />
          <el-table-column prop="issued" label="已领取" width="80" />
          <el-table-column prop="used" label="已使用" width="80" />
          <el-table-column prop="rate" label="核销率" width="100">
            <template #default="{ row }">
              <el-progress :percentage="row.rate" :stroke-width="10" />
            </template>
          </el-table-column>
          <el-table-column prop="revenue" label="带来营收" width="120">
            <template #default="{ row }">&yen;{{ row.revenue }}</template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

const usageTrendRef = ref<HTMLElement>()

const filterForm = reactive({ dateRange: null as any })

const couponStats = ref([
  { name: '新人50减10', issued: 456, used: 230, rate: 50.4, revenue: '12,800' },
  { name: '午市折扣券', issued: 320, used: 180, rate: 56.3, revenue: '18,500' },
  { name: '周年庆满减', issued: 2000, used: 1500, rate: 75.0, revenue: '86,200' },
])

const handleQuery = () => { /* TODO */ }
onMounted(() => { /* TODO: ECharts */ })
</script>
