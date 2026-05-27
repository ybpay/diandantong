<template>
  <div class="min-h-screen bg-gray-50">
    <van-nav-bar
      title="我的"
      fixed
      placeholder
    />

    <!-- User Info -->
    <div class="bg-white p-4 flex items-center gap-3">
      <van-image
        :src="userInfo.avatar || ''"
        round
        width="60"
        height="60"
        fit="cover"
      />
      <div>
        <h2 class="text-lg font-bold text-gray-800">{{ userInfo.nickname || '微信用户' }}</h2>
        <p class="text-sm text-gray-500">{{ userInfo.phone || '未绑定手机号' }}</p>
      </div>
    </div>

    <!-- Quick Stats -->
    <van-grid :column-num="3" class="mt-2" :border="false">
      <van-grid-item icon="orders-o" text="我的订单" to="/orders" />
      <van-grid-item icon="gold-coin-o" text="会员中心" to="/vip" />
      <van-grid-item icon="coupon-o" text="优惠券" to="/vip/coupons" />
    </van-grid>

    <!-- Menu Items -->
    <van-cell-group class="mt-4">
      <van-cell title="收货地址" is-link icon="location-o" />
      <van-cell title="我的收藏" is-link icon="like-o" />
      <van-cell title="浏览记录" is-link icon="clock-o" />
      <van-cell title="联系客服" is-link icon="service-o" />
      <van-cell title="关于我们" is-link icon="info-o" />
    </van-cell-group>

    <!-- Logout -->
    <div class="mt-6 px-4" v-if="authStore.isLoggedIn">
      <van-button type="danger" plain block @click="handleLogout">
        退出登录
      </van-button>
    </div>

    <!-- Bottom TabBar -->
    <van-tabbar v-model="activeTab" route>
      <van-tabbar-item icon="home-o" to="/home">首页</van-tabbar-item>
      <van-tabbar-item icon="orders-o" to="/orders">订单</van-tabbar-item>
      <van-tabbar-item icon="contact" to="/profile">我的</van-tabbar-item>
    </van-tabbar>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showDialog } from 'vant'
import { useH5AuthStore } from '@/stores/auth'
import { h5Client } from '@/api/client'

interface UserInfo {
  nickname: string
  avatar: string
  phone: string
}

const router = useRouter()
const authStore = useH5AuthStore()
const activeTab = ref(2)
const userInfo = ref<UserInfo>({
  nickname: '',
  avatar: '',
  phone: '',
})

onMounted(async () => {
  try {
    const { data } = await h5Client.get('/user/profile')
    userInfo.value = data
  } catch {
    // Use defaults
  }
})

async function handleLogout(): Promise<void> {
  try {
    await showDialog({ title: '确认退出', message: '确定要退出登录吗？' })
    authStore.logout()
    router.replace('/auth')
  } catch {
    // User cancelled
  }
}
</script>
