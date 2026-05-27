<template>
  <div class="min-h-screen bg-gray-50 pb-20">
    <!-- Product Image -->
    <van-image
      :src="product.image"
      width="100%"
      height="280"
      fit="cover"
    />

    <!-- Product Info -->
    <div class="bg-white p-4">
      <h1 class="text-xl font-bold text-gray-800">{{ product.name }}</h1>
      <p class="mt-1 text-sm text-gray-500">{{ product.description }}</p>
      <div class="mt-3 flex items-baseline gap-1">
        <span class="text-sm text-red-500">¥</span>
        <span class="text-2xl font-bold text-red-500">{{ product.price.toFixed(2) }}</span>
      </div>
    </div>

    <!-- Variants -->
    <div v-if="product.variants && product.variants.length > 0" class="bg-white mt-2 p-4">
      <h3 class="text-sm font-bold text-gray-700 mb-2">规格</h3>
      <van-radio-group v-model="selectedVariant" direction="horizontal">
        <van-radio
          v-for="variant in product.variants"
          :key="variant.name"
          :name="variant.name"
          class="mb-2"
        >
          {{ variant.name }} (¥{{ variant.price.toFixed(2) }})
        </van-radio>
      </van-radio-group>
    </div>

    <!-- Quantity -->
    <div class="bg-white mt-2 p-4 flex items-center justify-between">
      <span class="text-sm font-bold text-gray-700">数量</span>
      <van-stepper v-model="quantity" min="1" max="99" />
    </div>

    <!-- Bottom Action Bar -->
    <div class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 p-3 flex items-center justify-between">
      <div class="flex items-center gap-4">
        <van-icon name="shop-o" size="24" @click="router.push('/home')" />
        <van-icon name="cart-o" size="24" :badge="cartStore.totalCount || ''" @click="router.push('/cart')" />
      </div>
      <div class="flex gap-2">
        <van-button type="primary" plain @click="addToCart">加入购物车</van-button>
        <van-button type="danger" @click="buyNow">立即购买</van-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'
import { useCartStore } from '@/stores/cart'
import { h5Client } from '@/api/client'

interface Variant {
  name: string
  price: number
}

interface Product {
  id: number
  name: string
  price: number
  description: string
  image: string
  variants: Variant[]
  branchId: number
}

const router = useRouter()
const route = useRoute()
const cartStore = useCartStore()

const branchId = computed(() => Number(route.params.branchId))
const productId = computed(() => Number(route.params.productId))

const product = ref<Product>({
  id: 0,
  name: '',
  price: 0,
  description: '',
  image: '',
  variants: [],
  branchId: 0,
})
const selectedVariant = ref('')
const quantity = ref(1)

onMounted(async () => {
  try {
    const { data } = await h5Client.get(`/branches/${branchId.value}/products/${productId.value}`)
    product.value = data
    if (data.variants && data.variants.length > 0) {
      selectedVariant.value = data.variants[0].name
    }
  } catch {
    showToast('商品不存在')
    router.back()
  }
})

function getCurrentPrice(): number {
  if (selectedVariant.value && product.value.variants) {
    const variant = product.value.variants.find((v) => v.name === selectedVariant.value)
    if (variant) return variant.price
  }
  return product.value.price
}

function addToCart(): void {
  cartStore.addItem({
    productId: product.value.id,
    name: product.value.name,
    price: getCurrentPrice(),
    quantity: quantity.value,
    image: product.value.image,
    branchId: branchId.value,
    variants: selectedVariant.value,
  })
  showToast('已加入购物车')
}

function buyNow(): void {
  cartStore.addItem({
    productId: product.value.id,
    name: product.value.name,
    price: getCurrentPrice(),
    quantity: quantity.value,
    image: product.value.image,
    branchId: branchId.value,
    variants: selectedVariant.value,
  })
  router.push('/order/confirm')
}
</script>
