<template>
  <div>
    <h2 class="text-xl font-bold text-gray-800 mb-6">控制台</h2>

    <!-- Stats Cards -->
    <el-row :gutter="20" class="mb-6">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="text-center">
            <el-icon :size="32" class="text-blue-500"><OfficeBuilding /></el-icon>
            <p class="text-3xl font-bold text-gray-800 mt-2">{{ stats.totalMerchants }}</p>
            <p class="text-sm text-gray-500 mt-1">总商户数</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="text-center">
            <el-icon :size="32" class="text-green-500"><CircleCheck /></el-icon>
            <p class="text-3xl font-bold text-gray-800 mt-2">{{ stats.activeMerchants }}</p>
            <p class="text-sm text-gray-500 mt-1">活跃商户</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="text-center">
            <el-icon :size="32" class="text-orange-500"><Money /></el-icon>
            <p class="text-3xl font-bold text-gray-800 mt-2">¥{{ stats.totalRevenue }}</p>
            <p class="text-sm text-gray-500 mt-1">总收入</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="text-center">
            <el-icon :size="32" class="text-red-500"><Timer /></el-icon>
            <p class="text-3xl font-bold text-gray-800 mt-2">{{ stats.expiringSoon }}</p>
            <p class="text-sm text-gray-500 mt-1">即将到期</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Recent Merchants -->
    <el-card class="mb-6">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="font-bold">最近商户</span>
          <el-button text type="primary" @click="router.push('/merchants')">
            查看全部
          </el-button>
        </div>
      </template>
      <el-table :data="recentMerchants" stripe>
        <el-table-column prop="name" label="商户名称" />
        <el-table-column prop="contact_name" label="联系人" width="120" />
        <el-table-column prop="phone" label="联系电话" width="140" />
        <el-table-column prop="status_label" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">
              {{ row.status_label }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="expires_at" label="到期时间" width="180" />
      </el-table>
    </el-card>

    <!-- Expiring Soon -->
    <el-card>
      <template #header>
        <div class="flex items-center justify-between">
          <span class="font-bold">即将到期</span>
          <el-button text type="primary" @click="router.push('/expirations')">
            查看全部
          </el-button>
        </div>
      </template>
      <el-table :data="expiringMerchants" stripe>
        <el-table-column prop="name" label="商户名称" />
        <el-table-column prop="expires_at" label="到期时间" width="180" />
        <el-table-column prop="days_left" label="剩余天数" width="100">
          <template #default="{ row }">
            <el-tag type="danger" size="small">{{ row.days_left }}天</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button text type="primary" @click="router.push(`/merchants/${row.id}`)">
              查看
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { agentClient } from '@/api/client'

interface Stats {
  totalMerchants: number
  activeMerchants: number
  totalRevenue: string
  expiringSoon: number
}

interface Merchant {
  id: number
  name: string
  contact_name: string
  phone: string
  status: string
  status_label: string
  expires_at: string
  days_left?: number
}

const router = useRouter()
const stats = ref<Stats>({
  totalMerchants: 0,
  activeMerchants: 0,
  totalRevenue: '0.00',
  expiringSoon: 0,
})
const recentMerchants = ref<Merchant[]>([])
const expiringMerchants = ref<Merchant[]>([])

function statusTagType(status: string): 'success' | 'warning' | 'danger' | 'info' {
  const map: Record<string, 'success' | 'warning' | 'danger' | 'info'> = {
    active: 'success',
    trial: 'warning',
    expired: 'danger',
    suspended: 'info',
  }
  return map[status] || 'info'
}

onMounted(async () => {
  try {
    const { data } = await agentClient.get('/dashboard')
    stats.value = data.stats
    recentMerchants.value = data.recent_merchants
    expiringMerchants.value = data.expiring_merchants
  } catch {
    // Use defaults
  }
})
</script>
