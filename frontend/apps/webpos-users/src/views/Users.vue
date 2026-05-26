<template>
  <div class="min-h-screen flex flex-col bg-gray-100">
    <header class="flex items-center justify-between bg-blue-600 text-white px-6 py-3 shadow-md">
      <div class="flex items-center gap-4">
        <h1 class="text-lg font-bold">会员管理</h1>
        <span v-if="authStore.currentBranch" class="text-sm opacity-80">{{ authStore.currentBranch.name }}</span>
      </div>
      <div class="flex items-center gap-4">
        <el-button text class="text-white" @click="goBack">切换门店</el-button>
        <el-dropdown @command="handleCommand">
          <span class="cursor-pointer text-white">
            {{ authStore.userName }} <el-icon class="ml-1"><arrow-down /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>

    <main class="flex-1 p-6">
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex gap-4 mb-6">
          <el-input
            v-model="keyword"
            placeholder="搜索会员 (手机号/姓名/卡号)"
            clearable
            class="w-80"
            @keyup.enter="handleSearch"
          >
            <template #prefix>
              <el-icon><search /></el-icon>
            </template>
          </el-input>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
        </div>

        <el-table
          v-loading="loading"
          :data="vipList"
          stripe
          class="w-full"
          @row-click="goToDetail"
          row-class-name="cursor-pointer"
        >
          <el-table-column prop="card_no" label="卡号" width="140" />
          <el-table-column prop="name" label="姓名" width="120" />
          <el-table-column prop="phone" label="手机号" width="140" />
          <el-table-column prop="level_name" label="等级" width="100">
            <template #default="{ row }">
              <el-tag :type="getLevelTagType(row.level)">{{ row.level_name }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="余额" width="120" align="right">
            <template #default="{ row }">
              <span class="font-medium text-green-600">{{ formatPrice(row.balance) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="积分" width="100" align="right">
            <template #default="{ row }">
              <span class="font-medium">{{ row.credits }}</span>
            </template>
          </el-table-column>
          <el-table-column label="折扣率" width="100" align="center">
            <template #default="{ row }">
              {{ row.discount_rate > 0 ? `${(row.discount_rate * 100).toFixed(0)}%` : '-' }}
            </template>
          </el-table-column>
        </el-table>

        <div v-if="total > perPage" class="flex justify-center mt-6">
          <el-pagination
            v-model:current-page="currentPage"
            :page-size="perPage"
            :total="total"
            layout="prev, pager, next"
            @current-change="fetchUsers"
          />
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowDown, Search } from '@element-plus/icons-vue'
import { useAuthStore } from '@webpos/stores'
import { vipInfoApi } from '@webpos/api'
import { formatPrice } from '@webpos/composables'
import type { VipInfo } from '@webpos/types'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const keyword = ref('')
const vipList = ref<VipInfo[]>([])
const loading = ref(false)
const currentPage = ref(1)
const perPage = ref(20)
const total = ref(0)

const branchId = ref(Number(route.params.branchId))

onMounted(() => {
  fetchUsers()
})

async function handleSearch() {
  currentPage.value = 1
  await fetchUsers()
}

async function fetchUsers() {
  loading.value = true
  try {
    const params: { page: number; per_page: number; keyword?: string } = {
      page: currentPage.value,
      per_page: perPage.value,
    }
    if (keyword.value.trim()) {
      params.keyword = keyword.value.trim()
    }
    const { data } = await vipInfoApi.list(branchId.value, params)
    vipList.value = data.data
    total.value = data.total
  } catch {
    ElMessage.error('加载会员列表失败')
  } finally {
    loading.value = false
  }
}

function goToDetail(row: VipInfo) {
  router.push({
    name: 'userDetail',
    params: { branchId: branchId.value, vipInfoId: row.id },
  })
}

function getLevelTagType(level: number): 'primary' | 'success' | 'warning' | 'danger' | 'info' {
  if (level >= 4) return 'danger'
  if (level >= 3) return 'warning'
  if (level >= 2) return 'primary'
  return 'info'
}

function goBack() {
  router.push({ name: 'shop' })
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'login' })
    }).catch(() => {})
  }
}
</script>
