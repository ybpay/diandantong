<template>
  <div class="p-6 space-y-4">
    <h2 class="text-lg font-semibold">员工统计</h2>

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

    <!-- Worker Performance Table -->
    <el-card shadow="hover">
      <template #header><span class="font-semibold">员工绩效排行</span></template>
      <el-table :data="workers" stripe style="width: 100%">
        <el-table-column prop="rank" label="排名" width="70">
          <template #default="{ row }">
            <span :class="row.rank <= 3 ? 'text-red-500 font-bold' : ''">{{ row.rank }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="员工姓名" width="120" />
        <el-table-column prop="role" label="角色" width="100" />
        <el-table-column prop="orderCount" label="处理订单" width="100" />
        <el-table-column prop="totalAmount" label="成交金额" width="120">
          <template #default="{ row }">&yen;{{ row.totalAmount }}</template>
        </el-table-column>
        <el-table-column prop="avgResponseTime" label="平均响应" width="120" />
        <el-table-column prop="workHours" label="工时(h)" width="100" />
        <el-table-column prop="score" label="评分" width="100">
          <template #default="{ row }">
            <el-rate v-model="row.score" disabled :max="5" />
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <el-card shadow="hover">
        <template #header><span class="font-semibold">工时统计</span></template>
        <div ref="workHoursChartRef" class="h-64 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 工时柱状图</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header><span class="font-semibold">绩效趋势</span></template>
        <div ref="performanceChartRef" class="h-64 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 绩效折线图</p>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

const workHoursChartRef = ref<HTMLElement>()
const performanceChartRef = ref<HTMLElement>()

const filterForm = reactive({ dateRange: null as any })

const workers = ref([
  { rank: 1, name: '收银员A', role: '收银', orderCount: 520, totalAmount: '38,600', avgResponseTime: '2分钟', workHours: 168, score: 4.5 },
  { rank: 2, name: '服务员B', role: '服务员', orderCount: 380, totalAmount: '28,200', avgResponseTime: '3分钟', workHours: 160, score: 4.2 },
  { rank: 3, name: '厨师C', role: '后厨', orderCount: 680, totalAmount: '52,000', avgResponseTime: '8分钟', workHours: 176, score: 4.8 },
  { rank: 4, name: '收银员D', role: '收银', orderCount: 310, totalAmount: '22,800', avgResponseTime: '2.5分钟', workHours: 152, score: 4.0 },
])

const handleQuery = () => { /* TODO */ }
onMounted(() => { /* TODO: ECharts */ })
</script>
