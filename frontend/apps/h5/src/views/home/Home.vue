<template>
  <div class="min-h-screen bg-gray-50 pb-16">
    <!-- Shop Banner -->
    <div class="relative h-48 bg-gradient-to-r from-orange-400 to-red-500">
      <div class="absolute inset-0 flex items-center justify-center text-white">
        <div class="text-center">
          <h1 class="text-2xl font-bold">{{ shopInfo.name || '点单通' }}</h1>
          <p class="mt-1 text-sm opacity-90">{{ shopInfo.slogan || '美味生活，触手可及' }}</p>
        </div>
      </div>
    </div>

    <!-- Quick Links -->
    <div class="px-4 -mt-6">
      <van-grid :column-num="4" :border="false" class="rounded-lg overflow-hidden shadow-sm">
        <van-grid-item icon="shop-o" text="点餐" to="/home" @click="goMenu" />
        <van-grid-item icon="friends-o" text="排队" to="/home" @click="goQueue" />
        <van-grid-item icon="gold-coin-o" text="会员" to="/vip" />
        <van-grid-item icon="orders-o" text="订单" to="/orders" />
      </van-grid>
    </div>

    <!-- Shop Categories -->
    <div class="mt-4 px-4">
      <h2 class="text-lg font-bold text-gray-800 mb-3">热门分类</h2>
      <van-grid :column-num="3" :border="false" :gutter="10">
        <van-grid-item
          v-for="category in categories"
          :key="category.id"
          @click="goCategory(category.id)"
        >
          <template #icon>
            <van-image
              :src="category.image || '/placeholder-category.png'"
              width="48"
              height="48"
              round
              fit="cover"
            />
          </template>
          <template #text>
            <span class="text-xs text-gray-600 mt-1">{{ category.name }}</span>
          </template>
        </van-grid-item>
      </van-grid>
    </div>

    <!-- Recommended Products -->
    <div class="mt-6 px-4">
      <h2 class="text-lg font-bold text-gray-800 mb-3">推荐菜品</h2>
      <van-card
        v-for="product in recommendedProducts"
        :key="product.id"
        :price="product.price.toFixed(2)"
        :title="product.name"
        :thumb="product.image"
        class="mb-3"
      >
        <template #footer>
          <van-button size="small" type="primary" @click="addProduct(product)">
            加入购物车
          </van-button>
        </template>
      </van-card>
    </div>

    <!-- Shop Info -->
    <div class="mt-6 px-4">
      <h2 class="text-lg font-bold text-gray-800 mb-3">门店信息</h2>
      <van-cell-group>
        <van-cell title="地址" :value="shopInfo.address || '暂无'" icon="location-o" />
        <van-cell title="电话" :value="shopInfo.phone || '暂无'" icon="phone-o" />
        <van-cell title="营业时间" :value="shopInfo.businessHours || '暂无'" icon="clock-o" />
      </van-cell-group>
    </div>

    <!-- Bottom TabBar -->
    <van-tabbar v-model="activeTab" route>
      <van-tabbar-item icon="home-o" to="/home">首页</van-tabbar-item>
      <van-tabbar-item icon="orders-o" to="/orders">订单</van-tabbar-item>
      <van-tabbar-item icon="contact" to="/profile">我的</van-tabbar-item>
    </van-tabbar>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { useCartStore } from '@/stores/cart'
import { h5Client } from '@/api/client'

interface ShopInfo {
  name: string
  slogan: string
  address: string
  phone: string
  businessHours: string
  defaultBranchId: number
}

interface Category {
  id: number
  name: string
  image: string
}

interface Product {
  id: number
  name: string
  price: number
  image: string
  branchId: number
}

const router = useRouter()
const cartStore = useCartStore()

const activeTab = ref(0)
const shopInfo = ref<ShopInfo>({
  name: '',
  slogan: '',
  address: '',
  phone: '',
  businessHours: '',
  defaultBranchId: 0,
})
const categories = ref<Category[]>([])
const recommendedProducts = ref<Product[]>([])

onMounted(async () => {
  try {
    const [shopRes, categoriesRes, productsRes] = await Promise.all([
      h5Client.get('/shop'),
      h5Client.get('/categories'),
      h5Client.get('/products/recommended'),
    ])
    shopInfo.value = shopRes.data
    categories.value = categoriesRes.data
    recommendedProducts.value = productsRes.data
  } catch {
    // Use defaults on error
  }
})

function goMenu(): void {
  const branchId = shopInfo.value.defaultBranchId
  if (branchId) {
    router.push(`/menu/${branchId}`)
  }
}

function goQueue(): void {
  const branchId = shopInfo.value.defaultBranchId
  if (branchId) {
    router.push(`/queue/${branchId}`)
  }
}

function goCategory(categoryId: number): void {
  const branchId = shopInfo.value.defaultBranchId
  if (branchId) {
    router.push(`/menu/${branchId}?category=${categoryId}`)
  }
}

function addProduct(product: Product): void {
  cartStore.addItem({
    productId: product.id,
    name: product.name,
    price: product.price,
    quantity: 1,
    image: product.image,
    branchId: product.branchId,
  })
  showToast('已加入购物车')
}
</script>
