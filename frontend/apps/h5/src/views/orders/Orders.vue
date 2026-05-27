<template>
  <div class="min-h-screen bg-gray-50">
    <van-nav-bar
      title="我的订单"
      left-text="返回"
      left-arrow
      @click-left="router.push('/home')"
      fixed
      placeholder
    />

    <van-tabs v-model:active="activeTab" sticky offset-top="46">
      <van-tab title="全部" name="all" />
      <van-tab title="待处理" name="pending" />
      <van-tab title="已完成" name="completed" />
      <van-tab title="已取消" name="cancelled" />
    </van-tabs>

    <div class="p-4">
      <template v-if="filteredOrders.length > 0">
        <van-card
          v-for="order in filteredOrders"
          :key="order.id"
          :price="order.total_amount.toFixed(2)"
          :title="`订单号：${order.order_no}`"
          :desc="orderItemsText(order)"
        >
          <template #footer>
            <van-button
              size="small"
              type="primary"
              @click="router.push(`/orders/${order.id}`)"
            >
              查看详情
            </van-button>
          </template>
        </van-card>
      </template>
      <van-empty v-else description="暂无订单" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
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
  items: OrderItem[]
}

const router = useRouter()
const activeTab = ref('all')
const orders = ref<Order[]>([])

const filteredOrders = computed(() => {
  if (activeTab.value === 'all') return orders.value
  return orders.value.filter((o) => o.status === activeTab.value)
})

function orderItemsText(order: Order): string {
  return order.items?.map((i) => `${i.name}x${i.quantity}`).join('、') || ''
}

onMounted(async () => {
  try {
    const { data } = await h5Client.get('/orders')
    orders.value = data
  } catch {
    // Use empty list
  }
})
</script>
