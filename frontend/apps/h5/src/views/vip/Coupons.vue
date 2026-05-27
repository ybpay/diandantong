<template>
  <div class="min-h-screen bg-gray-50">
    <van-nav-bar
      title="我的优惠券"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <van-tabs v-model:active="activeTab" sticky offset-top="46">
      <van-tab title="可使用" name="available">
        <coupon-list :coupons="availableCoupons" />
      </van-tab>
      <van-tab title="已使用" name="used">
        <coupon-list :coupons="usedCoupons" />
      </van-tab>
      <van-tab title="已过期" name="expired">
        <coupon-list :coupons="expiredCoupons" />
      </van-tab>
    </van-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { h5Client } from '@/api/client'

interface Coupon {
  id: number
  name: string
  discount: number
  min_amount: number
  status: string
  expires_at: string
}

const activeTab = ref('available')
const coupons = ref<Coupon[]>([])

const availableCoupons = computed(() => coupons.value.filter((c) => c.status === 'available'))
const usedCoupons = computed(() => coupons.value.filter((c) => c.status === 'used'))
const expiredCoupons = computed(() => coupons.value.filter((c) => c.status === 'expired'))

onMounted(async () => {
  try {
    const { data } = await h5Client.get('/user/coupons')
    coupons.value = data
  } catch {
    // Use empty list
  }
})
</script>
