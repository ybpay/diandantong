<template>
  <PosLayout title="点餐" :branch-name="authStore.currentBranch?.name" :user-name="authStore.userName" @command="handleCommand">
    <div class="flex h-full">
      <div class="flex-1 p-4 overflow-y-auto">
        <div class="mb-4 flex gap-2 flex-wrap">
          <el-button
            v-for="cat in categories"
            :key="cat.id"
            :type="selectedCategory === cat.id ? 'primary' : 'default'"
            size="small"
            @click="selectedCategory = selectedCategory === cat.id ? null : cat.id"
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
          @add-note="addNote"
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
const tableId = computed(() => Number(route.params.tableId))
const products = ref<Product[]>([])
const categories = ref<{ id: number; name: string }[]>([])
const selectedCategory = ref<number | null>(null)

const cartItems = computed(() => {
  const cart = cartStore.getCart(branchId.value, 'eat_in_hall')
  return cart?.items || []
})

const filteredProducts = computed(() => {
  if (!selectedCategory.value) return products.value
  return products.value.filter((p) => p.category_id === selectedCategory.value)
})

async function fetchData() {
  try {
    const [prodRes, catRes] = await Promise.all([
      productApi.list(branchId.value),
      productApi.listCategories(branchId.value),
    ])
    products.value = prodRes.data.data
    categories.value = catRes.data
    await cartStore.fetchCart(branchId.value, 'eat_in_hall')
  } catch {
    ElMessage.error('加载数据失败')
  }
}

async function addToCart(product: Product) {
  const item: CartItem = {
    product_id: product.id,
    product_name: product.name,
    price: product.price,
    original_price: product.original_price,
    quantity: 1,
    is_gift: false,
    is_separate: false,
  }
  try {
    await cartStore.addItem(branchId.value, 'eat_in_hall', item)
  } catch {
    ElMessage.error('添加失败')
  }
}

async function removeCartItem(itemId: number) {
  try {
    await cartStore.removeItem(branchId.value, 'eat_in_hall', itemId)
  } catch {
    ElMessage.error('删除失败')
  }
}

async function changeQuantity(index: number, quantity: number) {
  const cart = cartStore.getCart(branchId.value, 'eat_in_hall')
  if (!cart) return
  const item = cart.items[index]
  if (!item) return
  if (quantity <= 0) {
    await cartStore.removeItem(branchId.value, 'eat_in_hall', item.id!)
  } else {
    await cartStore.updateItem(branchId.value, 'eat_in_hall', { ...item, quantity })
  }
}

function addNote() {
  ElMessageBox.prompt('请输入备注', '备注').then(async ({ value }) => {
    const cart = cartStore.getCart(branchId.value, 'eat_in_hall')
    if (cart && cart.items.length > 0 && value) {
      const lastItem = cart.items[cart.items.length - 1]
      if (lastItem.id) {
        await cartStore.changeNote(branchId.value, 'eat_in_hall', lastItem.id, value)
      }
    }
  }).catch(() => {})
}

async function placeOrder() {
  try {
    await cartStore.placeCart(branchId.value, 'eat_in_hall', {
      table_id: tableId.value,
    })
    ElMessage.success('下单成功')
    router.back()
  } catch (e: unknown) {
    ElMessage.error((e as { message?: string }).message || '下单失败')
  }
}

async function clearCart() {
  try {
    await cartStore.clearCart(branchId.value, 'eat_in_hall')
  } catch {
    // ignore
  }
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}

onMounted(fetchData)
</script>
