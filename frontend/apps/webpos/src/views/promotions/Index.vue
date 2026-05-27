<template>
  <PosLayout title="促销管理" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6"><p class="text-gray-500">促销管理页面开发中</p></div>
  </PosLayout>
</template>
<script setup lang="ts">
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'

const router = useRouter()
const authStore = useAuthStore()
function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => { await authStore.logout(); router.push({ name: 'signIn' }) }).catch(() => {})
  }
}
</script>
