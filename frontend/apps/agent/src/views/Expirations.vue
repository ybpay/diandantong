<template>
  <div>
    <h2 class="text-xl font-bold text-gray-800 mb-6">到期管理</h2>

    <!-- Summary Cards -->
    <el-row :gutter="20" class="mb-6">
      <el-col :span="8">
        <el-card shadow="hover">
          <div class="text-center">
            <p class="text-3xl font-bold text-red-500">{{ summary.expired }}</p>
            <p class="text-sm text-gray-500 mt-1">已过期</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <div class="text-center">
            <p class="text-3xl font-bold text-orange-500">{{ summary.expiring7Days }}</p>
            <p class="text-sm text-gray-500 mt-1">7天内到期</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <div class="text-center">
            <p class="text-3xl font-bold text-yellow-500">{{ summary.expiring30Days }}</p>
            <p class="text-sm text-gray-500 mt-1">30天内到期</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Filters -->
    <el-card class="mb-4">
      <el-form :inline="true">
        <el-form-item label="筛选">
          <el-select v-model="filter" @change="fetchMerchants">
            <el-option label="全部" value="all" />
            <el-option label="已过期" value="expired" />
            <el-option label="7天内到期" value="7days" />
            <el-option label="30天内到期" value="30days" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-input v-model="keyword" placeholder="搜索商户名称" clearable @clear="fetchMerchants" @keyup.enter="fetchMerchants" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchMerchants">搜索</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Table -->
    <el-card>
      <el-table :data="merchants" stripe v-loading="loading">
        <el-table-column prop="name" label="商户名称" min-width="150" />
        <el-table-column prop="contact_name" label="联系人" width="120" />
        <el-table-column prop="phone" label="联系电话" width="140" />
        <el-table-column prop="plan_name" label="套餐" width="120" />
        <el-table-column prop="expires_at" label="到期时间" width="180" />
        <el-table-column prop="days_left" label="剩余天数" width="100">
          <template #default="{ row }">
            <el-tag :type="row.days_left <= 0 ? 'danger' : row.days_left <= 7 ? 'warning' : 'info'" size="small">
              {{ row.days_left <= 0 ? '已过期' : `${row.days_left}天` }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" @click="router.push(`/merchants/${row.id}`)">
              查看
            </el-button>
            <el-button text type="success" @click="handleRenew(row)">
              续费
            </el-button>
            <el-button text type="warning" @click="handleNotify(row)">
              通知
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="mt-4 flex justify-end">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @size-change="fetchMerchants"
          @current-change="fetchMerchants"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { agentClient } from '@/api/client'

interface ExpiringMerchant {
  id: number
  name: string
  contact_name: string
  phone: string
  plan_name: string
  expires_at: string
  days_left: number
}

interface Summary {
  expired: number
  expiring7Days: number
  expiring30Days: number
}

const router = useRouter()
const loading = ref(false)
const merchants = ref<ExpiringMerchant[]>([])
const filter = ref('all')
const keyword = ref('')

const summary = ref<Summary>({
  expired: 0,
  expiring7Days: 0,
  expiring30Days: 0,
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0,
})

async function fetchMerchants(): Promise<void> {
  loading.value = true
  try {
    const { data } = await agentClient.get('/merchants/expirations', {
      params: {
        filter: filter.value,
        keyword: keyword.value || undefined,
        page: pagination.page,
        per_page: pagination.pageSize,
      },
    })
    merchants.value = data.merchants
    pagination.total = data.total
    summary.value = data.summary
  } catch {
    // Use defaults
  } finally {
    loading.value = false
  }
}

async function handleRenew(merchant: ExpiringMerchant): Promise<void> {
  try {
    await ElMessageBox.prompt(`为"${merchant.name}"续费，请输入天数`, '续费', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      inputPattern: /^\d+$/,
      inputErrorMessage: '请输入有效天数',
    }).then(async ({ value }) => {
      await agentClient.post(`/merchants/${merchant.id}/renew`, { days: Number(value) })
      ElMessage.success('续费成功')
      fetchMerchants()
    })
  } catch {
    // User cancelled
  }
}

async function handleNotify(merchant: ExpiringMerchant): Promise<void> {
  try {
    await agentClient.post(`/merchants/${merchant.id}/notify_expiration`)
    ElMessage.success('通知已发送')
  } catch {
    ElMessage.error('发送失败')
  }
}

onMounted(() => {
  fetchMerchants()
})
</script>
