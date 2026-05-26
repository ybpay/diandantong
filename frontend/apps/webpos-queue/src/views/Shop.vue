<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
        <h1 class="text-xl font-semibold text-gray-800">点单通 - 排队管理</h1>
        <div class="flex items-center gap-4">
          <span class="text-sm text-gray-600">{{ authStore.username }}</span>
          <el-button type="danger" size="small" @click="handleLogout">
            退出登录
          </el-button>
        </div>
      </div>
    </header>

    <main class="max-w-7xl mx-auto px-4 py-8">
      <h2 class="text-lg font-medium text-gray-700 mb-6">请选择门店</h2>
      <BranchSelector
        :branches="branches"
        :loading="loading"
        @select="handleBranchSelect"
      />
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElButton } from 'element-plus'
import { BranchSelector } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { shopApi } from '@webpos/api'

const router = useRouter()
const authStore = useAuthStore()

const branches = ref<Array<{ id: string; name: string; address?: string }>>([])
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  try {
    branches.value = await shopApi.getBranches()
  } catch (error) {
    console.error('Failed to load branches:', error)
  } finally {
    loading.value = false
  }
})

function handleBranchSelect(branch: { id: string }) {
  router.push({ name: 'Queue', params: { branchId: branch.id } })
}

function handleLogout() {
  authStore.logout()
  router.push({ name: 'Login' })
}
</script>
