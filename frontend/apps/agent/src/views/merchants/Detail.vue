<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-xl font-bold text-gray-800">商户详情</h2>
      <el-button @click="router.back()">返回</el-button>
    </div>

    <template v-if="merchant">
      <!-- Basic Info -->
      <el-card class="mb-4">
        <template #header>
          <div class="flex items-center justify-between">
            <span class="font-bold">基本信息</span>
            <el-button text type="primary" @click="router.push(`/merchants/${merchantId}`)">
              编辑
            </el-button>
          </div>
        </template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="商户名称">{{ merchant.name }}</el-descriptions-item>
          <el-descriptions-item label="联系人">{{ merchant.contact_name }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ merchant.phone }}</el-des-descriptions-item>
          <el-descriptions-item label="邮箱">{{ merchant.email }}</el-descriptions-item>
          <el-descriptions-item label="地址">{{ merchant.address }}</el-des-descriptions-item>
          <el-descriptions-item label="创建时间">{{ merchant.created_at }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <!-- Status & Subscription -->
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card>
            <template #header>
              <span class="font-bold">状态信息</span>
            </template>
            <el-descriptions :column="1" border>
              <el-descriptions-item label="当前状态">
                <el-tag :type="statusTagType(merchant.status)">
                  {{ merchant.status_label }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="套餐">{{ merchant.plan_name }}</el-descriptions-item>
              <el-descriptions-item label="开通时间">{{ merchant.activated_at }}</el-descriptions-item>
              <el-descriptions-item label="到期时间">
                <span :class="{ 'text-red-500 font-bold': isExpiringSoon }">
                  {{ merchant.expires_at }}
                </span>
              </el-descriptions-item>
            </el-descriptions>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <template #header>
              <span class="font-bold">使用统计</span>
            </template>
            <el-descriptions :column="1" border>
              <el-descriptions-item label="门店数">{{ merchant.branch_count }}</el-descriptions-item>
              <el-descriptions-item label="员工数">{{ merchant.worker_count }}</el-descriptions-item>
              <el-descriptions-item label="本月订单">{{ merchant.monthly_orders }}</el-descriptions-item>
              <el-descriptions-item label="本月收入">¥{{ merchant.monthly_revenue }}</el-descriptions-item>
            </el-descriptions>
          </el-card>
        </el-col>
      </el-row>

      <!-- Actions -->
      <el-card class="mt-4">
        <template #header>
          <span class="font-bold">操作</span>
        </template>
        <div class="flex gap-3">
          <el-button type="primary" @click="handleRenew">续费</el-button>
          <el-button type="warning" v-if="merchant.status === 'active'" @click="handleSuspend">
            停用
          </el-button>
          <el-button type="success" v-if="merchant.status === 'suspended'" @click="handleActivate">
            启用
          </el-button>
          <el-button type="danger" @click="handleResetPassword">重置密码</el-button>
        </div>
      </el-card>
    </template>

    <el-skeleton v-else :rows="10" animated />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { agentClient } from '@/api/client'

interface Merchant {
  id: number
  name: string
  contact_name: string
  phone: string
  email: string
  address: string
  status: string
  status_label: string
  plan_name: string
  activated_at: string
  expires_at: string
  branch_count: number
  worker_count: number
  monthly_orders: number
  monthly_revenue: string
}

const router = useRouter()
const route = useRoute()
const merchantId = computed(() => route.params.id as string)
const merchant = ref<Merchant | null>(null)

const isExpiringSoon = computed(() => {
  if (!merchant.value?.expires_at) return false
  const expiresAt = new Date(merchant.value.expires_at)
  const now = new Date()
  const diff = (expiresAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
  return diff <= 30
})

function statusTagType(status: string): 'success' | 'warning' | 'danger' | 'info' {
  const map: Record<string, 'success' | 'warning' | 'danger' | 'info'> = {
    active: 'success',
    trial: 'warning',
    expired: 'danger',
    suspended: 'info',
  }
  return map[status] || 'info'
}

async function fetchMerchant(): Promise<void> {
  try {
    const { data } = await agentClient.get(`/merchants/${merchantId.value}`)
    merchant.value = data
  } catch {
    ElMessage.error('商户不存在')
    router.back()
  }
}

async function handleRenew(): Promise<void> {
  try {
    await ElMessageBox.prompt('请输入续费天数', '续费', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      inputPattern: /^\d+$/,
      inputErrorMessage: '请输入有效天数',
    }).then(async ({ value }) => {
      await agentClient.post(`/merchants/${merchantId.value}/renew`, { days: Number(value) })
      ElMessage.success('续费成功')
      fetchMerchant()
    })
  } catch {
    // User cancelled
  }
}

async function handleSuspend(): Promise<void> {
  try {
    await ElMessageBox.confirm('确定要停用该商户吗？', '确认停用')
    await agentClient.put(`/merchants/${merchantId.value}/suspend`)
    ElMessage.success('已停用')
    fetchMerchant()
  } catch {
    // User cancelled
  }
}

async function handleActivate(): Promise<void> {
  try {
    await ElMessageBox.confirm('确定要启用该商户吗？', '确认启用')
    await agentClient.put(`/merchants/${merchantId.value}/activate`)
    ElMessage.success('已启用')
    fetchMerchant()
  } catch {
    // User cancelled
  }
}

async function handleResetPassword(): Promise<void> {
  try {
    await ElMessageBox.confirm('确定要重置该商户密码吗？', '确认重置')
    await agentClient.post(`/merchants/${merchantId.value}/reset_password`)
    ElMessage.success('密码已重置')
  } catch {
    // User cancelled
  }
}

onMounted(() => {
  fetchMerchant()
})
</script>
