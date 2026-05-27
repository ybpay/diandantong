<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 p-4">
    <div class="text-center">
      <van-loading v-if="loading" size="36px" vertical>
        微信授权登录中...
      </van-loading>
      <template v-else-if="error">
        <van-icon name="warning" size="48" color="#ee0a24" />
        <p class="mt-4 text-gray-600">{{ error }}</p>
        <van-button type="primary" class="mt-4" @click="retryAuth">
          重新登录
        </van-button>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useH5AuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useH5AuthStore()

const loading = ref(true)
const error = ref('')

onMounted(async () => {
  const code = route.query.code as string
  if (!code) {
    error.value = '缺少微信授权码'
    loading.value = false
    return
  }

  try {
    await authStore.login(code)
    const redirect = (route.query.state as string) || '/home'
    router.replace(redirect)
  } catch (e: any) {
    error.value = e.response?.data?.message || '登录失败，请重试'
    loading.value = false
  }
})

function retryAuth(): void {
  loading.value = true
  error.value = ''
  const appId = import.meta.env.VITE_WECHAT_APP_ID || ''
  const redirectUri = encodeURIComponent(window.location.origin + '/#/auth')
  window.location.href = `https://open.weixin.qq.com/connect/oauth2/authorize?appid=${appId}&redirect_uri=${redirectUri}&response_type=code&scope=snsapi_userinfo&state=/home#wechat_redirect`
}
</script>
