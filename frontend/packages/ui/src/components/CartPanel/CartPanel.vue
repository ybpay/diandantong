<template>
  <div class="cart-panel flex flex-col h-full bg-white border-l border-gray-200">
    <div class="cart-header p-3 border-b border-gray-200">
      <div class="flex items-center justify-between">
        <h3 class="font-bold text-gray-800">购物车</h3>
        <el-button size="small" type="danger" text @click="emit('clear')">清空</el-button>
      </div>
    </div>

    <div class="cart-items flex-1 overflow-y-auto p-3">
      <div v-if="items.length === 0" class="text-center text-gray-400 py-8">
        购物车为空
      </div>
      <div
        v-for="(item, index) in items"
        :key="index"
        class="cart-item flex items-center gap-2 py-2 border-b border-gray-100 last:border-0"
      >
        <div class="flex-1 min-w-0">
          <div class="text-sm font-medium truncate">{{ item.product_name }}</div>
          <div v-if="item.variant_name" class="text-xs text-gray-500">{{ item.variant_name }}</div>
          <div v-if="item.note" class="text-xs text-orange-500">{{ item.note }}</div>
        </div>
        <div class="flex items-center gap-1">
          <el-button size="small" circle @click="emit('changeQuantity', index, item.quantity - 1)">
            <el-icon><minus /></el-icon>
          </el-button>
          <span class="w-8 text-center text-sm">{{ item.quantity }}</span>
          <el-button size="small" circle @click="emit('changeQuantity', index, item.quantity + 1)">
            <el-icon><plus /></el-icon>
          </el-button>
        </div>
        <div class="text-sm font-medium text-primary-600 w-16 text-right">
          {{ formatPrice(item.price * item.quantity) }}
        </div>
        <el-button size="small" type="danger" text @click="emit('removeItem', index)">
          <el-icon><delete /></el-icon>
        </el-button>
      </div>
    </div>

    <div class="cart-footer p-3 border-t border-gray-200 space-y-2">
      <div class="flex justify-between text-sm">
        <span>商品数: {{ totalQuantity }}</span>
        <span class="font-bold text-lg">合计: {{ formatPrice(totalPrice) }}</span>
      </div>
      <div class="flex gap-2">
        <el-button class="flex-1" @click="emit('addNote')" :disabled="items.length === 0">
          备注
        </el-button>
        <el-button class="flex-1" type="primary" @click="emit('place')" :disabled="items.length === 0">
          下单
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Minus, Plus, Delete } from '@element-plus/icons-vue'
import type { CartItem } from '@webpos/types'
import { formatPrice } from '@webpos/composables'

const props = defineProps<{
  items: CartItem[]
}>()

const emit = defineEmits<{
  (e: 'removeItem', index: number): void
  (e: 'changeQuantity', index: number, quantity: number): void
  (e: 'clear'): void
  (e: 'place'): void
  (e: 'addNote'): void
}>()

const totalQuantity = computed(() =>
  props.items.reduce((sum, item) => sum + item.quantity, 0)
)

const totalPrice = computed(() =>
  props.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
)
</script>
