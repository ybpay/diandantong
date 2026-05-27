<template>
  <div>
    <h2 class="text-xl font-bold text-gray-800 mb-6">数据统计</h2>

    <!-- Date Range Filter -->
    <el-card class="mb-4">
      <el-form :inline="true">
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            @change="fetchStatistics"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchStatistics">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Summary Cards -->
    <el-row :gutter="20" class="mb-6">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="text-center">
            <p class="text-3xl font-bold text-blue-500">{{ summary.newMerchants }}</p>
            <p class="text-sm text-gray-500 mt-1">新增商户</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="text-center">
            <p class="text-3xl font-bold text-green-500">¥{{ summary.totalRevenue }}</p>
            <p class="text-sm text-gray-500 mt-1">总收入</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="text-center">
            <p class="text-3xl font-bold text-orange-500">{{ summary.renewCount }}</p>
            <p class="text-sm text-gray-500 mt-1">续费次数</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="text-center">
            <p class="text-3xl font-bold text-purple-500">{{ summary.activeMerchants }}</p>
            <p class="text-sm text-gray-500 mt-1">活跃商户</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Revenue Trend Chart Placeholder -->
    <el-card class="mb-4">
      <template #header>
        <span class="font-bold">收入趋势</span>
      </template>
      <div class="h-64 flex items-center justify-center bg-gray-50 rounded">
        <div class="text-center text-gray-400">
          <el-icon :size="48"><TrendCharts /></el-icon>
          <p class="mt-2">收入趋势图表</p>
          <p class="text-sm">集成 ECharts 后展示</p>
        </div>
      </div>
    </el-card>

    <!-- Merchant Growth Chart Placeholder -->
    <el-card class="mb-4">
      <template #header>
        <span class="font-bold">商户增长</span>
      </template>
      <div class="h-64 flex items-center justify-center bg-gray-50 rounded">
        <div class="text-center text-gray-400">
          <el-icon :size="48"><DataBoard /></el-icon>
          <p class="mt-2">商户增长图表</p>
          <p class="text-sm">集成 ECharts 后展示</p>
        </div>
      </div>
    </el-card>

    <!-- Commission Details -->
    <el-card>
      <template #header>
        <span class="font-bold">佣金明细</span>
      </template>
      <el-table :data="commissions" stripe>
        <el-table-column prop="merchant_name" label="商户" min-width="150" />
        <el-table-column prop="order_amount" label="订单金额" width="120" />
        <el-table-column prop="commission_rate" label="佣金比例" width="100" />
        <el-table-column prop="commission_amount" label="佣金金额" width="120" />
        <el-table-column prop="created_at" label="时间" width="180" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { agentClient } from '@/api/client'

interface Summary {
  newMerchants: number
  totalRevenue: string
  renewCount: number
  activeMerchants: number
}

interface Commission {
  merchant_name: string
  order_amount: string
  commission_rate: string
  commission_amount: string
  created_at: string
}

const dateRange = ref<[string, string] | null>(null)
const summary = ref<Summary>({
  newMerchants: 0,
  totalRevenue: '0.00',
  renewCount: 0,
  activeMerchants: 0,
})
const commissions = ref<Commission[]>([])

async function fetchStatistics(): Promise<void> {
  try {
    const params: Record<string, string> = {}
    if (dateRange.value) {
      params.start_date = dateRange.value[0]
      params.end_date = dateRange.value[1]
    }
    const { data } = await agentClient.get('/statistics', { params })
    summary.value = data.summary
    commissions.value = data.commissions || []
  } catch {
    // Use defaults
  }
}

onMounted(() => {
  fetchStatistics()
})
</script>
