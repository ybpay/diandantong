<template>
  <PosLayout title="会员管理" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6">
      <div class="flex gap-4 mb-4">
        <el-input v-model="keyword" placeholder="搜索会员 (手机号/姓名/卡号)" clearable @keyup.enter="searchVip" class="w-80" />
        <el-button type="primary" @click="searchVip">搜索</el-button>
      </div>
      <el-table :data="vipList" stripe>
        <el-table-column prop="card_no" label="卡号" width="120" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="level_name" label="等级" width="80" />
        <el-table-column label="余额" width="100">
          <template #default="{ row }">{{ formatPrice(row.balance) }}</template>
        </el-table-column>
        <el-table-column label="积分" width="80">
          <template #default="{ row }">{{ row.credits }}</template>
        </el-table-column>
      </el-table>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { vipInfoApi } from '@webpos/api'
import { formatPrice } from '@webpos/composables'
import type { VipInfo } from '@webpos/types'

const router = useRouter()
const authStore = useAuthStore()
const keyword = ref('')
const vipList = ref<VipInfo[]>([])

async function searchVip() {
  if (!keyword.value) return
  try {
    const { data } = await vipInfoApi.search(keyword.value)
    vipList.value = data
  } catch {
    ElMessage.error('搜索失败')
  }
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}
</script>
