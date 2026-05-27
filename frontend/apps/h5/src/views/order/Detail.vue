<template>
  <div class="min-h-screen bg-gray-50">
    <van-nav-bar
      title="订单详情"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <template v-if="order">
      <!-- Status Timeline -->
      <div class="bg-white p-4 mt-2">
        <h3 class="text-sm font-bold text-gray-700 mb-3">订单状态</h3>
        <van-steps :active="activeStep" direction="vertical">
          <van-step>下单成功</van-step>
          <van-step>商家确认</van-step>
          <van-step>制作中</van-step>
          <van-step>已完成</van-step>
        </van-steps>
      </div>

      <!-- Items -->
      <van-cell-group class="mt-2" title="订单明细">
        <van-cell
          v-for="item in order.items"
          :key="item.name"
          :title="item.name"
          :value="`x${item.quantity}`"
          :label="`¥${item.price.toFixed(2)}`"
        />
      </van-cell-group>

      <!-- Payment Info -->
      <van-cell-group class="mt-2" title="支付信息">
        <van-cell title="订单号" :value="order.order_no" />
        <van-cell title="下单时间" :value="order.created_at" />
        <van-cell title="支付方式" :value="order.payment_method_label || '微信支付'" />
        <van-cell title="订单金额">
          <template #value>
            <span class="text-red-500 font-bold">¥{{ order.total_amount.toFixed(2) }}</span>
          </template>
        </van-cell>
      </van-cell-group>

      <!-- Actions -->
      <div class="p-4 flex gap-3">
        <van-button
          v-if="order.status === 'pending'"
          type="danger"
          block
          @click="cancelOrder"
        >
          取消订单
        </van-button>
        <van-button
          v-if="order.status === 'completed' && !order.has_review"
          type="primary"
          block
        >
          评价
        </van-button>
        <van-button
          v-if="order.status === 'pending'"
          type="primary"
          block
          @click="router.push(`/pay/${order.id}`)"
        >
          去支付
        </van-button>
      </div>
    </template>

    <van-loading v-else class="mt-20" size="36px" vertical>加载中...</van-loading>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast, showDialog } from 'vant'
import { h5Client } from '@/api/client'

interface OrderItem {
  name: string
  quantity: number
  price: number
}

interface Order {
  id: number
  order_no: string
  status: string
  total_amount: number
  created_at: string
  payment_method_label: string
  has_review: boolean
  items: OrderItem[]
}

const router = useRouter()
const route = useRoute()
const orderId = computed(() => route.params.id as string)
const order = ref<Order | null>(null)

const activeStep = computed(() => {
  if (!order.value) return 0
  const statusMap: Record<string, number> = {
    pending: 0,
    confirmed: 1,
    preparing: 2,
    completed: 3,
  }
  return statusMap[order.value.status] ?? 0
})

onMounted(async () => {
  try {
    const { data } = await h5Client.get(`/orders/${orderId.value}`)
    order.value = data
  } catch {
    showToast('订单不存在')
    router.back()
  }
})

async function cancelOrder(): Promise<void> {
  try {
    await showDialog({ title: '确认取消', message: '确定要取消该订单吗？' })
    await h5Client.put(`/orders/${orderId.value}/cancel`)
    showToast('订单已取消')
    order.value!.status = 'cancelled'
  } catch {
    // User cancelled dialog or API error
  }
}
</script>
