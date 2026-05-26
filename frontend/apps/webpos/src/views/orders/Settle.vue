<template>
  <PosLayout title="订单结算" :branch-name="authStore.currentBranch?.name" :user-name="authStore.userName" @command="handleCommand">
    <div class="flex items-center justify-center h-full">
      <div class="w-[500px]">
        <OrderSettle
          :order="orderStore.currentOrder"
          :loading="loading"
          @pay="handlePay"
          @cancel="router.back()"
        />
      </div>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout, OrderSettle } from '@webpos/ui'
import { useAuthStore, useOrderStore } from '@webpos/stores'
import type { OrderType, PaymentMethod } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const orderStore = useOrderStore()

const branchId = computed(() => Number(route.params.branchId))
const orderId = computed(() => Number(route.params.orderId))
const orderType = computed(() => route.params.orderType as OrderType)
const loading = ref(false)

async function handlePay(method: PaymentMethod) {
  loading.value = true
  try {
    await orderStore.completeOrder(branchId.value, orderType.value, orderId.value)
    ElMessage.success('支付成功')
    router.push({ name: 'orders', params: { branchId: branchId.value } })
  } catch (e: unknown) {
    ElMessage.error((e as { message?: string }).message || '支付失败')
  } finally {
    loading.value = false
  }
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}

onMounted(async () => {
  await orderStore.fetchOrder(branchId.value, orderType.value, orderId.value)
})
</script>
