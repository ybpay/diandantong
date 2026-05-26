<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { PosLayout } from '@webpos/ui'
import { useOrderStore } from '@webpos/stores'
import { formatPrice, waitTime, useActionCable } from '@webpos/composables'
import type { Order, LineItem } from '@webpos/types'

const route = useRoute()
const orderStore = useOrderStore()

const branchId = computed(() => route.params.branchId as string)
const orders = computed(() => orderStore.activeOrders)

// Real-time updates via WebSocket
const cable = useActionCable()

function handleOrderCreated(data: { order: Order }) {
  if (data.order.branch_id === branchId.value) {
    orderStore.addOrder(data.order)
  }
}

function handleOrderUpdated(data: { order: Order }) {
  orderStore.updateOrder(data.order)
}

function handleOrderHastened(data: { order_id: string }) {
  orderStore.markHastened(data.order_id)
}

cable.subscribe('KitchenChannel', {
  received(payload: { action: string; data: unknown }) {
    switch (payload.action) {
      case 'order_created':
        handleOrderCreated(payload.data as { order: Order })
        break
      case 'order_updated':
        handleOrderUpdated(payload.data as { order: Order })
        break
      case 'order_hastened':
        handleOrderHastened(payload.data as { order_id: string })
        break
    }
  },
})

// Auto-refresh every 30 seconds
let refreshTimer: ReturnType<typeof setInterval> | null = null

onMounted(async () => {
  await orderStore.fetchActiveOrders(branchId.value)

  refreshTimer = setInterval(() => {
    orderStore.fetchActiveOrders(branchId.value)
  }, 30_000)
})

onUnmounted(() => {
  if (refreshTimer !== null) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }
})

// Actions
async function markItemDone(orderId: string, lineItemId: string) {
  await orderStore.markLineItemDone(orderId, lineItemId)
}

async function hastenOrder(orderId: string) {
  await orderStore.hastenOrder(orderId)
}

function getOrderWaitMinutes(order: Order): string {
  return waitTime(order.created_at)
}

function formatItemNote(lineItem: LineItem): string {
  if (lineItem.note) {
    return `(${lineItem.note})`
  }
  return ''
}
</script>

<template>
  <PosLayout title="后厨显示">
    <div class="kitchen-display">
      <!-- Header -->
      <div class="kitchen-header">
        <h2 class="kitchen-title">
          后厨订单
          <span class="order-count">{{ orders.length }} 单</span>
        </h2>
        <button
          class="refresh-btn"
          @click="orderStore.fetchActiveOrders(branchId)"
        >
          刷新
        </button>
      </div>

      <!-- Order Grid -->
      <div v-if="orders.length > 0" class="order-grid">
        <div
          v-for="order in orders"
          :key="order.id"
          class="order-card"
          :class="{ hastened: order.hastened }"
        >
          <!-- Order Header -->
          <div class="order-card-header">
            <span class="order-no">{{ order.order_no }}</span>
            <span
              v-if="order.hastened"
              class="hasten-badge"
            >
              催单
            </span>
            <span class="order-time">
              {{ getOrderWaitMinutes(order) }}
            </span>
          </div>

          <!-- Line Items -->
          <div class="order-items">
            <div
              v-for="item in order.line_items"
              :key="item.id"
              class="order-item"
              :class="{ done: item.status === 'done' }"
            >
              <div class="item-info">
                <span class="item-name">{{ item.product_name }}</span>
                <span class="item-quantity">x{{ item.quantity }}</span>
                <span
                  v-if="item.note"
                  class="item-note"
                >
                  {{ formatItemNote(item) }}
                </span>
              </div>
              <button
                v-if="item.status !== 'done'"
                class="done-btn"
                @click="markItemDone(order.id, item.id)"
              >
                完成
              </button>
              <span v-else class="done-label">已完成</span>
            </div>
          </div>

          <!-- Order Footer -->
          <div class="order-card-footer">
            <span class="order-total">
              合计: {{ formatPrice(order.total_amount) }}
            </span>
            <button
              v-if="!order.hastened"
              class="hasten-btn"
              @click="hastenOrder(order.id)"
            >
              催单
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <p class="empty-text">暂无待处理订单</p>
      </div>
    </div>
  </PosLayout>
</template>

<style scoped>
.kitchen-display {
  padding: 16px;
  min-height: 100vh;
  background-color: #1a1a2e;
  color: #eee;
}

.kitchen-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
  padding: 12px 16px;
  background-color: #16213e;
  border-radius: 8px;
}

.kitchen-title {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #fff;
}

.order-count {
  margin-left: 12px;
  font-size: 16px;
  font-weight: 400;
  color: #0f3460;
  background-color: #e94560;
  padding: 2px 10px;
  border-radius: 12px;
  color: #fff;
}

.refresh-btn {
  padding: 8px 20px;
  font-size: 14px;
  background-color: #0f3460;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.refresh-btn:hover {
  background-color: #1a4a8a;
}

/* Order Grid */
.order-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
}

/* Order Card */
.order-card {
  background-color: #16213e;
  border-radius: 12px;
  border: 2px solid #0f3460;
  overflow: hidden;
  transition: border-color 0.3s;
}

.order-card.hastened {
  border-color: #e94560;
  animation: pulse-border 1.5s ease-in-out infinite;
}

@keyframes pulse-border {
  0%, 100% { border-color: #e94560; }
  50% { border-color: #ff6b81; }
}

.order-card-header {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  background-color: #0f3460;
  gap: 8px;
}

.order-no {
  font-size: 20px;
  font-weight: 700;
  color: #fff;
  flex: 1;
}

.hasten-badge {
  background-color: #e94560;
  color: #fff;
  font-size: 12px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 4px;
  animation: blink 1s ease-in-out infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.order-time {
  font-size: 14px;
  color: #a0aec0;
}

/* Line Items */
.order-items {
  padding: 12px 16px;
}

.order-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #1a2744;
}

.order-item:last-child {
  border-bottom: none;
}

.order-item.done {
  opacity: 0.5;
}

.item-info {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.item-name {
  font-size: 16px;
  font-weight: 500;
  color: #e2e8f0;
}

.item-quantity {
  font-size: 16px;
  font-weight: 700;
  color: #e94560;
  min-width: 30px;
}

.item-note {
  font-size: 12px;
  color: #f6ad55;
  font-style: italic;
}

.done-btn {
  padding: 4px 16px;
  font-size: 13px;
  background-color: #38a169;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.done-btn:hover {
  background-color: #48bb78;
}

.done-label {
  font-size: 13px;
  color: #38a169;
  font-weight: 500;
}

/* Order Footer */
.order-card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  border-top: 1px solid #1a2744;
}

.order-total {
  font-size: 14px;
  color: #a0aec0;
}

.hasten-btn {
  padding: 4px 16px;
  font-size: 13px;
  background-color: transparent;
  color: #e94560;
  border: 1px solid #e94560;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.hasten-btn:hover {
  background-color: #e94560;
  color: #fff;
}

/* Empty State */
.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
}

.empty-text {
  font-size: 24px;
  color: #4a5568;
}
</style>
