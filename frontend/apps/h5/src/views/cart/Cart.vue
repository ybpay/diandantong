<template>
  <div class="min-h-screen bg-gray-50 pb-24">
    <van-nav-bar
      title="购物车"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <template v-if="cartStore.items.length > 0">
      <van-swipe-cell v-for="item in cartStore.items" :key="`${item.productId}-${item.variants}`">
        <van-card
          :price="item.price.toFixed(2)"
          :title="item.name"
          :thumb="item.image"
        >
          <template #footer>
            <van-stepper
              :model-value="item.quantity"
              min="0"
              max="99"
              @change="(val: number) => cartStore.updateQuantity(item.productId, val, item.variants)"
            />
          </template>
        </van-card>
        <template #right>
          <van-button
            square
            type="danger"
            text="删除"
            class="h-full"
            @click="cartStore.removeItem(item.productId, item.variants)"
          />
        </template>
      </van-swipe-cell>
    </template>

    <van-empty v-else description="购物车空空如也" />

    <!-- Submit Bar -->
    <van-submit-bar
      :price="Math.round(cartStore.totalPrice * 100)"
      button-text="去结算"
      :disabled="cartStore.items.length === 0"
      class="bottom-0"
      @submit="router.push('/order/confirm')"
    >
      <template #default>
        <van-button size="small" type="default" @click="cartStore.clear()">
          清空
        </van-button>
      </template>
    </van-submit-bar>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'

const router = useRouter()
const cartStore = useCartStore()
</script>
