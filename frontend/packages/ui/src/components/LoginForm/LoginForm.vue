<template>
  <div class="login-form min-h-screen flex items-center justify-center bg-gray-100">
    <el-card class="w-96 shadow-lg">
      <template #header>
        <h2 class="text-xl font-bold text-center">{{ title }}</h2>
      </template>
      <el-form ref="formRef" :model="form" :rules="rules" @submit.prevent="handleLogin">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="用户名" prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码" prefix-icon="Lock" size="large"
            show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" class="w-full" :loading="loading" @click="handleLogin">
            登录
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'

defineProps<{
  title?: string
  loading?: boolean
}>()

const emit = defineEmits<{
  (e: 'login', username: string, password: string): void
}>()

const formRef = ref()
const form = reactive({ username: '', password: '' })

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

async function handleLogin() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (valid) {
    emit('login', form.username, form.password)
  }
}
</script>
