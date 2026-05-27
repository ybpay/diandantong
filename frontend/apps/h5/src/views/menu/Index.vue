<template>
  <div class="min-h-screen bg-gray-50 flex flex-col">
    <!-- Header -->
    <van-nav-bar
      title="菜单"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <div class="flex flex-1 overflow-hidden">
      <!-- Category Sidebar -->
      <van-sidebar v-model="activeCategory" class="w-20 shrink-0 overflow-y-auto">
        <van-sidebar-item
          v-for="category in categories"
          :key="category.id"
          :title="category.name"
        />
      </van-sidebar>

      <!-- Product List -->
      <div class="flex-1 overflow-y-auto px-3 py-2">
        <template v-if="currentProducts.length > 0">
          <van-card
            v-for="product in currentProducts"
            :key="product.id"
            :price="product.price.toFixed(2)"
            :title="product.name"
            :desc="product.description"
            :thumb="product.image"
            class="mb-2"
            @click="goProductDetail(product.id)"
          >
            <template #footer>
              <van-button size="mini" type="primary" @click.stop="addToCart(product)">
                <van-icon name="cart-o" />
              </van-button>
            </template>
          </van-card>
        </template>
        <van-empty v-else description="暂无菜品" />
      </div>
    </div>

    <!-- Bottom Cart Bar -->
    <div class="sticky bottom-0 bg-white border-t border-gray-200 p-3 flex items-center justify-between">
      <div class="flex items-center gap-2" @click="router.push('/cart')">
        <van-icon name="cart-o" size="24" :badge="cartStore.totalCount || ''" />
        <span class="text-lg font-bold text-red-500">
          ¥{{ cartStore.totalPrice.toFixed(2) }}
        </span>
      </div>
      <van-button type="danger" round @click="goCheckout">
        去结算
      </van-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'
import { useCartStore } from '@/stores/cart'
import { h5Client } from '@/api/client'

interface Category {
  id: number
  name: string
}

interface Product {
  id: number
  name: string
  price: number
  description: string
  image: string
  categoryId: number
}

const router = useRouter()
const route = useRoute()
const cartStore = useCartStore()

const branchId = computed(() => Number(route.params.branchId))
const activeCategory = ref(0)
const categories = ref<Category[]>([])
const products = ref<Product[]>([])

const currentProducts = computed(() => {
  const category = categories.value[activeCategory.value]
  if (!category) return products.value
  return products.value.filter((p) => p.categoryId === category.id)
})

onMounted(async () => {
  try {
    const [categoriesRes, productsRes] = await Promise.all([
      h5Client.get(`/branches/${branchId.value}/categories`),
      h5Client.get(`/branches/${branchId.value}/products`),
    ])
    categories.value = categoriesRes.data
    products.value = productsRes.data

    const queryCategory = Number(route.query.category)
    if (queryCategory) {
      const idx = categories.value.findIndex((c) => c.id === queryCategory)
      if (idx !== -1) activeCategory.value = idx
    }
  } catch {
    // Use empty defaults
  }
})

function goProductDetail(productId: number): void {
  router.push(`/menu/${branchId.value}/product/${productId}`)
}

function addToCart(product: Product): void {
  cartStore.addItem({
    productId: product.id,
    name: product.name,
    price: product.price,
    quantity: 1,
    image: product.image,
    branchId: branchId.value,
  })
  showToast('已加入购物车')
}

function goCheckout(): void {
  if (cartStore.totalCount === 0) {
    showToast('购物车为空')
    return
  }
  router.push('/order/confirm')
}
</script>
