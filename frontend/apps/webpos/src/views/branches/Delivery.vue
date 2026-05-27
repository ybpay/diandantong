<template>
  <PosLayout
    title="收银台 - 外卖"
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
        <ProductGrid :products="products" :columns="5" @select="addToCart" />
      </div>
      <div class="w-96 flex flex-col">
        <div class="p-3 border-b">
          <el-button size="small" @click="showAddressDialog = true">选择地址</el-button>
          <div v-if="deliveryAddress" class="text-sm mt-2">
            {{ deliveryAddress.name }} {{ deliveryAddress.phone }} - {{ deliveryAddress.address }}
          </div>
        </div>
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
import type { Product, CartItem, DeliveryAddress } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const cartStore = useCartStore()

const branchId = computed(() => Number(route.params.branchId))
const products = ref<Product[]>([])
const deliveryAddress = ref<DeliveryAddress | null>(null)
const showAddressDialog = ref(false)

const cartItems = computed(() => {
  const cart = cartStore.getCart(branchId.value, 'delivery')
  return cart?.items || []
})

async function fetchProducts() {
  try {
    const { data } = await productApi.list(branchId.value)
    products.value = data.data
  } catch {
    ElMessage.error('加载商品失败')
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
    await cartStore.addItem(branchId.value, 'delivery', item)
  } catch {
    ElMessage.error('添加失败')
  }
}

async function removeCartItem(itemId: number) {
  try {
    await cartStore.removeItem(branchId.value, 'delivery', itemId)
  } catch {
    ElMessage.error('删除失败')
  }
}

async function changeQuantity(index: number, quantity: number) {
  const cart = cartStore.getCart(branchId.value, 'delivery')
  if (!cart) return
  const item = cart.items[index]
  if (!item) return
  if (quantity <= 0) {
    await cartStore.removeItem(branchId.value, 'delivery', item.id!)
  } else {
    await cartStore.updateItem(branchId.value, 'delivery', { ...item, quantity })
  }
}

async function placeOrder() {
  try {
    await cartStore.placeCart(branchId.value, 'delivery', {
      delivery_address_id: deliveryAddress.value?.id,
    })
    ElMessage.success('下单成功')
    deliveryAddress.value = null
  } catch (e: unknown) {
    ElMessage.error((e as { message?: string }).message || '下单失败')
  }
}

async function clearCart() {
  try {
    await cartStore.clearCart(branchId.value, 'delivery')
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

onMounted(fetchProducts)
</script>
