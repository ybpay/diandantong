<template>
  <div class="p-6 space-y-6">
    <!-- Welcome Section -->
    <div class="bg-gradient-to-r from-blue-500 to-indigo-600 rounded-lg p-6 text-white">
      <h1 class="text-2xl font-bold">欢迎回来，{{ userName }}</h1>
      <p class="mt-1 text-blue-100">今天是 {{ currentDate }}，祝您工作顺利！</p>
    </div>

    <!-- Stat Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <el-card shadow="hover" class="stat-card">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-500">今日订单</p>
            <p class="text-2xl font-bold text-gray-800 mt-1">{{ stats.todayOrders }}</p>
            <p class="text-xs mt-1" :class="stats.orderTrend >= 0 ? 'text-green-500' : 'text-red-500'">
              {{ stats.orderTrend >= 0 ? '+' : '' }}{{ stats.orderTrend }}% 较昨日
            </p>
          </div>
          <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-blue-500"><Document /></el-icon>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="stat-card">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-500">今日营收</p>
            <p class="text-2xl font-bold text-gray-800 mt-1">&yen;{{ stats.todayRevenue }}</p>
            <p class="text-xs mt-1" :class="stats.revenueTrend >= 0 ? 'text-green-500' : 'text-red-500'">
              {{ stats.revenueTrend >= 0 ? '+' : '' }}{{ stats.revenueTrend }}% 较昨日
            </p>
          </div>
          <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-green-500"><Money /></el-icon>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="stat-card">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-500">VIP会员</p>
            <p class="text-2xl font-bold text-gray-800 mt-1">{{ stats.vipCount }}</p>
            <p class="text-xs text-green-500 mt-1">+{{ stats.newVipToday }} 今日新增</p>
          </div>
          <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-purple-500"><User /></el-icon>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="stat-card">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-500">门店数量</p>
            <p class="text-2xl font-bold text-gray-800 mt-1">{{ stats.branchCount }}</p>
            <p class="text-xs text-gray-400 mt-1">{{ stats.activeBranches }} 家营业中</p>
          </div>
          <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-orange-500"><Shop /></el-icon>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Recent Orders & Quick Actions -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Recent Orders -->
      <el-card class="lg:col-span-2" shadow="hover">
        <template #header>
          <div class="flex items-center justify-between">
            <span class="font-semibold">最近订单</span>
            <el-button text type="primary" @click="$router.push('/orders')">查看全部</el-button>
          </div>
        </template>
        <el-table :data="recentOrders" stripe style="width: 100%">
          <el-table-column prop="orderNo" label="订单号" width="160" />
          <el-table-column prop="type" label="类型" width="100">
            <template #default="{ row }">
              <el-tag :type="orderTypeTag(row.type)" size="small">{{ row.type }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="100">
            <template #default="{ row }">&yen;{{ row.amount }}</template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="statusTag(row.status)" size="small">{{ row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="时间" />
        </el-table>
      </el-card>

      <!-- Quick Actions -->
      <el-card shadow="hover">
        <template #header>
          <span class="font-semibold">快捷操作</span>
        </template>
        <div class="space-y-3">
          <el-button class="w-full" type="primary" @click="$router.push('/products')">
            管理菜品
          </el-button>
          <el-button class="w-full" @click="$router.push('/orders')">查看订单</el-button>
          <el-button class="w-full" @click="$router.push('/vip')">VIP管理</el-button>
          <el-button class="w-full" @click="$router.push('/statistics')">数据统计</el-button>
          <el-button class="w-full" @click="$router.push('/settings')">系统设置</el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Document, Money, User, Shop } from '@element-plus/icons-vue'

const userName = ref('管理员')
const currentDate = computed(() => new Date().toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' }))

const stats = ref({
  todayOrders: 128,
  orderTrend: 12.5,
  todayRevenue: '8,650.00',
  revenueTrend: 8.3,
  vipCount: 1520,
  newVipToday: 15,
  branchCount: 5,
  activeBranches: 4,
})

const recentOrders = ref([
  { orderNo: 'DD20260527001', type: '堂食', amount: '128.00', status: '已完成', createdAt: '10:30' },
  { orderNo: 'DD20260527002', type: '外卖', amount: '56.00', status: '配送中', createdAt: '10:25' },
  { orderNo: 'DD20260527003', type: '快餐', amount: '35.00', status: '已完成', createdAt: '10:20' },
  { orderNo: 'DD20260527004', type: '团购', amount: '99.00', status: '待使用', createdAt: '10:15' },
  { orderNo: 'DD20260527005', type: '堂食', amount: '210.00', status: '进行中', createdAt: '10:10' },
])

const orderTypeTag = (type: string) => {
  const map: Record<string, string> = { '堂食': '', '外卖': 'warning', '快餐': 'success', '团购': 'info' }
  return map[type] ?? ''
}

const statusTag = (status: string) => {
  const map: Record<string, string> = { '已完成': 'success', '配送中': 'warning', '进行中': '', '待使用': 'info' }
  return map[status] ?? ''
}
</script>
