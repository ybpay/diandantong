<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart, LineChart, PieChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
} from 'echarts/components'

use([
  CanvasRenderer,
  BarChart,
  LineChart,
  PieChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
])

// Daily revenue chart option
const revenueOption = ref({
  title: { text: 'Daily Revenue (7 Days)' },
  tooltip: { trigger: 'axis' },
  xAxis: {
    type: 'category',
    data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  },
  yAxis: { type: 'value', name: 'Amount (CNY)' },
  series: [
    {
      name: 'Revenue',
      type: 'bar',
      data: [12000, 15000, 9800, 18200, 16500, 22000, 19800],
    },
    {
      name: 'Last Week',
      type: 'line',
      data: [11000, 14000, 10200, 17000, 15800, 21000, 18500],
    },
  ],
})

// Order distribution pie chart
const orderTypeOption = ref({
  title: { text: 'Order Distribution', left: 'center' },
  tooltip: { trigger: 'item' },
  legend: { orient: 'vertical', left: 'left' },
  series: [
    {
      name: 'Order Type',
      type: 'pie',
      radius: '50%',
      data: [
        { value: 1048, name: 'Dine-in' },
        { value: 735, name: 'Takeaway' },
        { value: 580, name: 'Delivery' },
        { value: 484, name: 'Fast-food' },
      ],
    },
  ],
})
</script>

<template>
  <div class="space-y-6 p-6">
    <h2 class="text-xl font-bold">ECharts 5 Integration Demo</h2>

    <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
      <div class="rounded-lg bg-white p-4 shadow">
        <VChart :option="revenueOption" style="height: 350px" autoresize />
      </div>
      <div class="rounded-lg bg-white p-4 shadow">
        <VChart :option="orderTypeOption" style="height: 350px" autoresize />
      </div>
    </div>
  </div>
</template>
