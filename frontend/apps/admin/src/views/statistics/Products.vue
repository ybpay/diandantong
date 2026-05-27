<template>
  <div class="p-6 space-y-4">
    <h2 class="text-lg font-semibold">菜品统计</h2>

    <el-card shadow="never">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="时间范围">
          <el-date-picker v-model="filterForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="filterForm.categoryId" placeholder="全部分类" clearable>
            <el-option label="热菜" :value="1" />
            <el-option label="凉菜" :value="2" />
            <el-option label="主食" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Sales Ranking -->
    <el-card shadow="hover">
      <template #header><span class="font-semibold">菜品销量排行 TOP 10</span></template>
      <el-table :data="topProducts" stripe style="width: 100%">
        <el-table-column prop="rank" label="排名" width="70">
          <template #default="{ row }">
            <span :class="row.rank <= 3 ? 'text-red-500 font-bold' : ''">{{ row.rank }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="菜品名称" min-width="200" />
        <el-table-column prop="categoryName" label="分类" width="120" />
        <el-table-column prop="salesCount" label="销量" width="100" />
        <el-table-column prop="salesAmount" label="销售额" width="120">
          <template #default="{ row }">&yen;{{ row.salesAmount }}</template>
        </el-table-column>
        <el-table-column prop="avgPrice" label="均价" width="100">
          <template #default="{ row }">&yen;{{ row.avgPrice }}</template>
        </el-table-column>
      </el-table>
    </el-card>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <el-card shadow="hover">
        <template #header><span class="font-semibold">分类销量占比</span></template>
        <div ref="categoryChartRef" class="h-64 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 分类饼图</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header><span class="font-semibold">销量趋势</span></template>
        <div ref="trendChartRef" class="h-64 flex items-center justify-center bg-gray-50 rounded">
          <p class="text-gray-400">ECharts 销量趋势图</p>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

const categoryChartRef = ref<HTMLElement>()
const trendChartRef = ref<HTMLElement>()

const filterForm = reactive({ dateRange: null as any, categoryId: undefined as number | undefined })

const topProducts = ref([
  { rank: 1, name: '蛋炒饭', categoryName: '主食', salesCount: 450, salesAmount: '6,750.00', avgPrice: '15.00' },
  { rank: 2, name: '宫保鸡丁', categoryName: '热菜', salesCount: 256, salesAmount: '9,728.00', avgPrice: '38.00' },
  { rank: 3, name: '凉拌黄瓜', categoryName: '凉菜', salesCount: 320, salesAmount: '3,840.00', avgPrice: '12.00' },
  { rank: 4, name: '糖醋排骨', categoryName: '热菜', salesCount: 189, salesAmount: '9,072.00', avgPrice: '48.00' },
  { rank: 5, name: '酸辣汤', categoryName: '汤品', salesCount: 210, salesAmount: '4,620.00', avgPrice: '22.00' },
])

const handleQuery = () => { /* TODO */ }
onMounted(() => { /* TODO: ECharts */ })
</script>
