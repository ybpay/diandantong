<template>
  <PosLayout
    title="收银台 - 快餐"
    :branch-name="authStore.currentBranch?.name"
    :branch-id="branchId"
    :user-name="authStore.userName"
    :show-notifications="true"
    @command="handleCommand"
  >
    <template #header-actions>
      <el-button text @click="router.push({ name: 'orders', params: { branchId } })">订单</el-button>
    </template>

    <div class="flex h-full">
      <div class="flex-1 p-4 overflow-y-auto">
        <div class="mb-4 flex gap-2">
          <el-button
            v-for="cat in categories"
            :key="cat.id"
            :type="selectedCategory === cat.id ? 'primary' : 'default'"
            size="small"
            @click="selectCategory(cat.id)"
          >
            {{ cat.name }}
          </el-button>
        </div>
        <ProductGrid :products="filteredProducts" :columns="5" @select="addToCart" />
      </div>
      <div class="w-96">
        <CartPanel
          :items="cartItems"
          @remove-item="removeCartItem"
          @change-quantity="changeQuantity"
          @place="placeOrder"
          @clear="clearCart"
        />
      </div>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout, ProductGrid, CartPanel } from '@webpos/ui'
import { useAuthStore, useCartStore } from '@webpos/stores'
import { productApi } from '@webpos/api'
import type { Product, CartItem } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const cartStore = useCartStore()

const branchId = computed(() => Number(route.params.branchId))
const products = ref<Product[]>([])
const categories = ref<{ id: number; name: string }[]>([])
const selectedCategory = ref<number | null>(null)
const cartItems = ref<CartItem[]>([])

const filteredProducts = computed(() => {
  if (!selectedCategory.value) return products.value
  return products.value.filter((p) => p.category_id === selectedCategory.value)
})

function selectCategory(catId: number) {
  selectedCategory.value = catId === selectedCategory.value ? null : catId
}

async function fetchProducts() {
  try {
    const [prodRes, catRes] = await Promise.all([
      productApi.list(branchId.value),
      productApi.listCategories(branchId.value),
    ])
    products.value = prodRes.data.data
    categories.value = catRes.data
  } catch {
    ElMessage.error('加载商品失败')
  }
}

function addToCart(product: Product) {
  const existing = cartItems.value.find(
    (i) => i.product_id === product.id && !i.is_gift && !i.note
  )
  if (existing) {
    existing.quantity++
  } else {
    cartItems.value.push({
      product_id: product.id,
      product_name: product.name,
      price: product.price,
      original_price: product.original_price,
      quantity: 1,
      is_gift: false,
      is_separate: false,
    })
  }
}

function removeCartItem(index: number) {
  cartItems.value.splice(index, 1)
}

function changeQuantity(index: number, quantity: number) {
  if (quantity <= 0) cartItems.value.splice(index, 1)
  else cartItems.value[index].quantity = quantity
}

async function placeOrder() {
  try {
    await cartStore.placeCart(branchId.value, 'fast_food', { items: cartItems.value })
    ElMessage.success('下单成功')
    cartItems.value = []
  } catch (e: unknown) {
    ElMessage.error((e as { message?: string }).message || '下单失败')
  }
}

function clearCart() {
  cartItems.value = []
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}

onMounted(fetchProducts)
</script>
