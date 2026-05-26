<script setup lang="ts">
import { LoginForm } from '@webpos/ui'
import { useRouter } from 'vue-router'

const router = useRouter()

function onLoginSuccess() {
  router.push({ name: 'shop' })
}
</script>

<template>
  <div class="login-page">
    <LoginForm @login-success="onLoginSuccess" />
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
