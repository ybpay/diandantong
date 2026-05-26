<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="w-full max-w-md">
      <h1 class="text-2xl font-bold text-center mb-8 text-gray-800">
        点单通 - 排队管理
      </h1>
      <LoginForm @login-success="handleLoginSuccess" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { LoginForm } from '@webpos/ui'

const router = useRouter()

function handleLoginSuccess() {
  router.push({ name: 'Shop' })
}
</script>
