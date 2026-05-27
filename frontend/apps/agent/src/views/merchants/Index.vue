<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-xl font-bold text-gray-800">商户管理</h2>
      <el-button type="primary" @click="router.push('/merchants/new')">
        <el-icon class="mr-1"><Plus /></el-icon>
        新建商户
      </el-button>
    </div>

    <!-- Filters -->
    <el-card class="mb-4">
      <el-form :inline="true" :model="filters">
        <el-form-item label="搜索">
          <el-input
            v-model="filters.keyword"
            placeholder="商户名称/联系人/电话"
            clearable
            @clear="fetchMerchants"
            @keyup.enter="fetchMerchants"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filters.status" placeholder="全部" clearable @change="fetchMerchants">
            <el-option label="活跃" value="active" />
            <el-option label="试用" value="trial" />
            <el-option label="已过期" value="expired" />
            <el-option label="已停用" value="suspended" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchMerchants">搜索</el-button>
          <el-button @click="resetFilters">重置</el-button>
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
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">
              {{ row.status_label }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="180" />
        <el-table-column prop="expires_at" label="到期时间" width="180" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" @click="router.push(`/merchants/${row.id}`)">
              查看
            </el-button>
            <el-button text type="primary" @click="router.push(`/merchants/${row.id}`)">
              编辑
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="mt-4 flex justify-end">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
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
import { agentClient } from '@/api/client'

interface Merchant {
  id: number
  name: string
  contact_name: string
  phone: string
  plan_name: string
  status: string
  status_label: string
  created_at: string
  expires_at: string
}

const router = useRouter()
const loading = ref(false)
const merchants = ref<Merchant[]>([])

const filters = reactive({
  keyword: '',
  status: '',
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0,
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

async function fetchMerchants(): Promise<void> {
  loading.value = true
  try {
    const { data } = await agentClient.get('/merchants', {
      params: {
        keyword: filters.keyword || undefined,
        status: filters.status || undefined,
        page: pagination.page,
        per_page: pagination.pageSize,
      },
    })
    merchants.value = data.merchants
    pagination.total = data.total
  } catch {
    // Use empty list
  } finally {
    loading.value = false
  }
}

function resetFilters(): void {
  filters.keyword = ''
  filters.status = ''
  pagination.page = 1
  fetchMerchants()
}

onMounted(() => {
  fetchMerchants()
})
</script>
