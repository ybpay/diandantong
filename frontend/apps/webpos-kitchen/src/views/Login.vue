<script setup lang="ts">
import { ref } from 'vue'
import { LoginForm } from '@webpos/ui'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@webpos/stores'

const router = useRouter()
const authStore = useAuthStore()
const loading = ref(false)

async function onLogin(username: string, password: string) {
  loading.value = true
  try {
    await authStore.login({ username, password })
    router.push({ name: 'shop' })
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <LoginForm :loading="loading" @login="onLogin" />
  </div>
</template>

<style scoped>
.login-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background-color: #f5f7fa;
}
</style>
