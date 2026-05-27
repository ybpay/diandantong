<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="w-full max-w-md">
      <h1 class="text-2xl font-bold text-center mb-8 text-gray-800">
        点单通 - 排队管理
      </h1>
      <LoginForm @login="handleLogin" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { LoginForm } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'

const router = useRouter()
const authStore = useAuthStore()

async function handleLogin(username: string, password: string) {
  await authStore.login({ username, password })
  router.push({ name: 'Shop' })
}
</script>
