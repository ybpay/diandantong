<template>
  <div class="min-h-screen bg-gray-50 pb-16">
    <van-nav-bar
      title="会员中心"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <!-- User Info Card -->
    <div class="mx-4 mt-4 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-xl p-5 text-white shadow-lg">
      <div class="flex items-center gap-3">
        <van-image
          :src="userInfo.avatar || ''"
          round
          width="56"
          height="56"
          fit="cover"
        />
        <div>
          <h2 class="text-lg font-bold">{{ userInfo.nickname || '微信用户' }}</h2>
          <p class="text-sm opacity-90">
            {{ userInfo.phone || '未绑定手机号' }}
          </p>
        </div>
      </div>
      <div class="mt-4 flex justify-around text-center">
        <div>
          <p class="text-2xl font-bold">¥{{ userInfo.balance.toFixed(2) }}</p>
          <p class="text-xs opacity-80 mt-1">余额</p>
        </div>
        <div>
          <p class="text-2xl font-bold">{{ userInfo.credits }}</p>
          <p class="text-xs opacity-80 mt-1">积分</p>
        </div>
        <div>
          <p class="text-2xl font-bold">{{ userInfo.couponCount }}</p>
          <p class="text-xs opacity-80 mt-1">优惠券</p>
        </div>
      </div>
    </div>

    <!-- Quick Links -->
    <van-cell-group class="mx-4 mt-4 rounded-lg overflow-hidden">
      <van-cell title="余额充值" is-link icon="gold-coin-o" to="/vip/recharge" />
      <van-cell title="我的优惠券" is-link icon="coupon-o" to="/vip/coupons" />
      <van-cell title="积分明细" is-link icon="points" />
      <van-cell title="会员等级" is-link icon="medal-o" />
    </van-cell-group>

    <!-- Recent Transactions -->
    <van-cell-group class="mx-4 mt-4 rounded-lg overflow-hidden" title="最近交易">
      <van-cell
        v-for="tx in recentTransactions"
        :key="tx.id"
        :title="tx.description"
        :value="tx.type === 'expense' ? `-${tx.amount}` : `+${tx.amount}`"
        :label="tx.created_at"
      />
      <van-empty v-if="recentTransactions.length === 0" description="暂无交易记录" />
    </van-cell-group>

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
import { h5Client } from '@/api/client'

interface UserInfo {
  nickname: string
  avatar: string
  phone: string
  balance: number
  credits: number
  couponCount: number
}

interface Transaction {
  id: number
  description: string
  amount: string
  type: 'income' | 'expense'
  created_at: string
}

const router = useRouter()
const activeTab = ref(2)
const userInfo = ref<UserInfo>({
  nickname: '',
  avatar: '',
  phone: '',
  balance: 0,
  credits: 0,
  couponCount: 0,
})
const recentTransactions = ref<Transaction[]>([])

onMounted(async () => {
  try {
    const [userRes, txRes] = await Promise.all([
      h5Client.get('/user/vip'),
      h5Client.get('/user/transactions', { params: { limit: 10 } }),
    ])
    userInfo.value = userRes.data
    recentTransactions.value = txRes.data
  } catch {
    // Use defaults
  }
})
</script>
