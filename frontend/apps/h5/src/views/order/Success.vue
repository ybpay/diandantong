<template>
  <div class="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-4">
    <van-icon name="checked" size="64" color="#07c160" />
    <h2 class="mt-4 text-xl font-bold text-gray-800">下单成功</h2>
    <p class="mt-2 text-sm text-gray-500">订单号：{{ orderNo }}</p>

    <div class="mt-6 bg-white rounded-lg p-4 w-full max-w-sm">
      <van-cell-group>
        <van-cell title="预计等待" :value="estimatedTime" />
        <van-cell title="支付状态" value="已支付" />
      </van-cell-group>
    </div>

    <div class="mt-8 flex gap-4">
      <van-button type="primary" plain @click="router.push('/orders')">
        查看订单
      </van-button>
      <van-button type="primary" @click="router.push('/home')">
        返回首页
      </van-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const orderNo = computed(() => (route.query.order_no as string) || '')
const estimatedTime = computed(() => (route.query.estimated_time as string) || '约15-20分钟')
</script>
