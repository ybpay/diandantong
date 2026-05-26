<template>
  <LoginForm title="点单通 - 清台" :loading="loading" @login="handleLogin" />
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { LoginForm } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'

const router = useRouter()
const authStore = useAuthStore()
const loading = ref(false)

async function handleLogin(username: string, password: string) {
  loading.value = true
  try {
    await authStore.login({ username, password })
    ElMessage.success('登录成功')
    router.push({ name: 'shop' })
  } catch (e: unknown) {
    const err = e as { message?: string }
    ElMessage.error(err.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>
