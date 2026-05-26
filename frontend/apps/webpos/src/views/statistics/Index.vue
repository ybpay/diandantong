<template>
  <PosLayout title="统计" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6">
      <h3 class="text-lg font-bold mb-4">经营统计</h3>
      <p class="text-gray-500">统计页面 - 图表展示开发中 (ECharts 5)</p>
    </div>
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
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}
</script>
