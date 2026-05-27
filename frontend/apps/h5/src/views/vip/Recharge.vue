<template>
  <div class="min-h-screen bg-gray-50">
    <van-nav-bar
      title="余额充值"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <div class="p-4">
      <h3 class="text-sm font-bold text-gray-700 mb-3">选择充值金额</h3>

      <!-- Recharge Products -->
      <div class="grid grid-cols-3 gap-3">
        <div
          v-for="product in rechargeProducts"
          :key="product.id"
          class="bg-white rounded-lg p-4 text-center border-2 transition-colors cursor-pointer"
          :class="selectedProduct?.id === product.id ? 'border-orange-500' : 'border-gray-100'"
          @click="selectedProduct = product"
        >
          <p class="text-2xl font-bold text-orange-500">¥{{ product.amount }}</p>
          <p v-if="product.bonus > 0" class="text-xs text-red-500 mt-1">
            赠送¥{{ product.bonus }}
          </p>
          <p class="text-xs text-gray-500 mt-1">{{ product.name }}</p>
        </div>
      </div>

      <!-- Pay Button -->
      <div class="mt-6">
        <van-button
          type="danger"
          block
          round
          size="large"
          :disabled="!selectedProduct"
          :loading="paying"
          @click="handleRecharge"
        >
          立即充值
        </van-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { h5Client } from '@/api/client'

interface RechargeProduct {
  id: number
  name: string
  amount: number
  bonus: number
}

const router = useRouter()
const rechargeProducts = ref<RechargeProduct[]>([])
const selectedProduct = ref<RechargeProduct | null>(null)
const paying = ref(false)

onMounted(async () => {
  try {
    const { data } = await h5Client.get('/recharge_products')
    rechargeProducts.value = data
  } catch {
    // Use empty list
  }
})

async function handleRecharge(): Promise<void> {
  if (!selectedProduct.value) return
  paying.value = true
  try {
    const { data } = await h5Client.post('/recharge', {
      product_id: selectedProduct.value.id,
    })
    showToast('充值成功')
    router.back()
  } catch (e: any) {
    showToast(e.response?.data?.message || '充值失败')
  } finally {
    paying.value = false
  }
}
</script>
