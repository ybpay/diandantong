<template>
  <div class="min-h-screen bg-gray-50">
    <van-nav-bar
      title="收银台"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <div class="p-4">
      <!-- Amount -->
      <div class="bg-white rounded-lg p-6 text-center mb-4">
        <p class="text-sm text-gray-500">支付金额</p>
        <p class="text-4xl font-bold text-red-500 mt-2">
          ¥{{ orderAmount.toFixed(2) }}
        </p>
      </div>

      <!-- Payment Methods -->
      <van-radio-group v-model="paymentMethod">
        <van-cell-group title="支付方式">
          <van-cell title="微信支付" clickable @click="paymentMethod = 'wechat'">
            <template #title>
              <div class="flex items-center gap-2">
                <van-icon name="wechat" size="20" color="#07c160" />
                <span>微信支付</span>
              </div>
            </template>
            <template #right-icon>
              <van-radio name="wechat" />
            </template>
          </van-cell>
          <van-cell title="支付宝" clickable @click="paymentMethod = 'alipay'">
            <template #title>
              <div class="flex items-center gap-2">
                <van-icon name="alipay" size="20" color="#1677ff" />
                <span>支付宝</span>
              </div>
            </template>
            <template #right-icon>
              <van-radio name="alipay" />
            </template>
          </van-cell>
        </van-cell-group>
      </van-radio-group>

      <!-- QR Code Placeholder -->
      <div v-if="showQRCode" class="bg-white rounded-lg p-6 mt-4 text-center">
        <p class="text-sm text-gray-500 mb-4">请扫描二维码支付</p>
        <div class="w-48 h-48 bg-gray-100 mx-auto flex items-center justify-center border-2 border-dashed border-gray-300 rounded-lg">
          <van-icon name="scan" size="48" color="#999" />
        </div>
        <p class="text-xs text-gray-400 mt-2">二维码将在5分钟后过期</p>
      </div>

      <!-- Pay Button -->
      <div class="mt-6">
        <van-button
          type="danger"
          block
          round
          size="large"
          :loading="paying"
          @click="handlePay"
        >
          确认支付
        </van-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'
import { h5Client } from '@/api/client'

const router = useRouter()
const route = useRoute()
const orderId = computed(() => route.params.orderId as string)

const orderAmount = ref(0)
const paymentMethod = ref('wechat')
const paying = ref(false)
const showQRCode = ref(false)

let pollTimer: ReturnType<typeof setInterval> | null = null
let pollTimeout: ReturnType<typeof setTimeout> | null = null

onMounted(async () => {
  try {
    const { data } = await h5Client.get(`/orders/${orderId.value}`)
    orderAmount.value = data.total_amount
  } catch {
    showToast('订单不存在')
    router.back()
  }
})

async function handlePay(): Promise<void> {
  paying.value = true
  try {
    const { data } = await h5Client.post(`/orders/${orderId.value}/pay`, {
      payment_method: paymentMethod.value,
    })
    if (data.qr_code_url) {
      showQRCode.value = true
      pollPaymentStatus()
    } else {
      showToast('支付成功')
      router.replace(`/order/success?order_no=${data.order_no}`)
    }
  } catch (e: any) {
    showToast(e.response?.data?.message || '支付失败')
  } finally {
    paying.value = false
  }
}

function pollPaymentStatus(): void {
  pollTimer = setInterval(async () => {
    try {
      const { data } = await h5Client.get(`/orders/${orderId.value}`)
      if (data.status === 'completed' || data.status === 'confirmed') {
        clearInterval(pollTimer!)
        pollTimer = null
        showToast('支付成功')
        router.replace(`/order/success?order_no=${data.order_no}`)
      }
    } catch {
      clearInterval(pollTimer!)
      pollTimer = null
    }
  }, 3000)

  pollTimeout = setTimeout(() => {
    if (pollTimer) {
      clearInterval(pollTimer)
      pollTimer = null
    }
  }, 300000)
}

onUnmounted(() => {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
  if (pollTimeout) {
    clearTimeout(pollTimeout)
    pollTimeout = null
  }
})
</script>
