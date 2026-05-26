<template>
  <div class="order-settle bg-white rounded-lg shadow-md">
    <div class="p-4 border-b border-gray-200">
      <h3 class="text-lg font-bold">结算</h3>
      <div class="text-sm text-gray-500 mt-1">订单号: {{ order?.order_no }}</div>
    </div>

    <div class="p-4 space-y-3">
      <div class="flex justify-between">
        <span>原价</span>
        <span>{{ formatPrice(order?.original_price || 0) }}</span>
      </div>
      <div v-if="order?.discount_amount" class="flex justify-between text-red-500">
        <span>优惠</span>
        <span>-{{ formatPrice(order.discount_amount) }}</span>
      </div>
      <el-divider />
      <div class="flex justify-between text-lg font-bold">
        <span>应付</span>
        <span class="text-primary-600">{{ formatPrice(order?.total_price || 0) }}</span>
      </div>

      <!-- Payment Methods -->
      <div class="space-y-2 mt-4">
        <h4 class="font-medium text-gray-700">支付方式</h4>
        <div class="grid grid-cols-3 gap-2">
          <el-button
            v-for="method in paymentMethods"
            :key="method.value"
            :type="selectedMethod === method.value ? 'primary' : 'default'"
            @click="selectedMethod = method.value"
          >
            {{ method.label }}
          </el-button>
        </div>
      </div>

      <!-- VIP -->
      <div v-if="order?.vip_info" class="mt-4 p-3 bg-blue-50 rounded">
        <div class="text-sm">
          <span>会员: {{ order.vip_info.name }}</span>
          <span class="ml-2">余额: {{ formatPrice(order.vip_info.balance) }}</span>
        </div>
      </div>

      <!-- Actions -->
      <div class="mt-4 flex gap-2">
        <el-button class="flex-1" @click="emit('cancel')">取消</el-button>
        <el-button
          class="flex-1"
          type="primary"
          size="large"
          @click="emit('pay', selectedMethod)"
          :loading="loading"
        >
          确认支付 {{ formatPrice(order?.total_price || 0) }}
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import type { Order, PaymentMethod } from '@webpos/types'
import { formatPrice } from '@webpos/composables'

defineProps<{
  order: Order | null
  loading?: boolean
}>()

const emit = defineEmits<{
  (e: 'pay', method: PaymentMethod): void
  (e: 'cancel'): void
}>()

const selectedMethod = ref<PaymentMethod>('cash')

const paymentMethods: { label: string; value: PaymentMethod }[] = [
  { label: '现金', value: 'cash' },
  { label: '微信', value: 'wechat' },
  { label: '支付宝', value: 'alipay' },
  { label: '银行卡', value: 'card' },
  { label: '会员余额', value: 'vip_balance' },
  { label: '积分', value: 'credits' },
]
</script>
