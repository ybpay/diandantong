<template>
  <div class="product-grid grid gap-2" :style="gridStyle">
    <div
      v-for="product in products"
      :key="product.id"
      class="product-card bg-white rounded-lg shadow-sm p-3 cursor-pointer hover:shadow-md transition-shadow border border-gray-200"
      :class="{ 'opacity-50': product.is_sold_out }"
      @click="handleSelect(product)"
    >
      <div class="text-sm font-medium truncate">{{ product.name }}</div>
      <div class="text-primary-600 font-bold mt-1">{{ formatPrice(product.price) }}</div>
      <div v-if="product.is_sold_out" class="text-xs text-red-500 mt-1">已售罄</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Product } from '@webpos/types'
import { formatPrice } from '@webpos/composables'

const props = defineProps<{
  products: Product[]
  columns?: number
}>()

const emit = defineEmits<{
  (e: 'select', product: Product): void
}>()

const gridStyle = computed(() => ({
  gridTemplateColumns: `repeat(${props.columns || 4}, 1fr)`,
}))

function handleSelect(product: Product) {
  if (!product.is_sold_out) {
    emit('select', product)
  }
}
</script>
