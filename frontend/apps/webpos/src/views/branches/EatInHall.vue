<template>
  <PosLayout
    title="收银台 - 堂食"
    :branch-name="authStore.currentBranch?.name"
    :branch-id="branchId"
    :user-name="authStore.userName"
    :show-notifications="true"
    @command="handleCommand"
  >
    <template #header-actions>
      <el-button text @click="router.push({ name: 'orders', params: { branchId } })">订单</el-button>
      <el-button text @click="router.push({ name: 'guestQueues', params: { branchId } })">排队</el-button>
      <el-button text @click="router.push({ name: 'printers', params: { branchId } })">打印机</el-button>
    </template>

    <div class="flex h-full">
      <!-- Left: Table Map -->
      <div class="w-2/5 p-4 overflow-y-auto">
        <TableMap :zones="zones" :tables="tables" @select="handleTableSelect" @refresh="fetchTables" />
      </div>

      <!-- Right: Order / Cart -->
      <div class="w-3/5 border-l border-gray-200">
        <div v-if="selectedTable" class="h-full flex flex-col">
          <div class="p-3 bg-gray-50 border-b flex items-center justify-between">
            <span class="font-bold">{{ selectedTable.name }}</span>
            <el-tag :type="selectedTable.status === 'idle' ? 'success' : 'danger'">
              {{ statusText(selectedTable.status) }}
            </el-tag>
          </div>

          <div v-if="selectedTable.status === 'idle'" class="flex-1 flex items-center justify-center">
            <el-button type="primary" size="large" @click="startOrder">
              开始点餐
            </el-button>
          </div>

          <div v-else class="flex-1 flex flex-col">
            <div class="flex-1 p-4 overflow-y-auto">
              <ProductGrid :products="products" :columns="4" @select="addToCart" />
            </div>
            <CartPanel
              :items="cartItems"
              class="w-full"
              @remove-item="removeCartItem"
              @change-quantity="changeQuantity"
              @place="placeOrder"
              @clear="clearCart"
            />
          </div>
        </div>

        <div v-else class="h-full flex items-center justify-center text-gray-400">
          请选择一个桌台
        </div>
      </div>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout, ProductGrid, CartPanel, TableMap } from '@webpos/ui'
import { useAuthStore, useCartStore } from '@webpos/stores'
import { tableApi, productApi } from '@webpos/api'
import type { Table, TableZone, Product, CartItem } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const cartStore = useCartStore()

const branchId = computed(() => Number(route.params.branchId))
const zones = ref<TableZone[]>([])
const tables = ref<Table[]>([])
const products = ref<Product[]>([])
const selectedTable = ref<Table | null>(null)

const cartItems = computed(() => {
  const cart = cartStore.getCart(branchId.value, 'eat_in_hall')
  return cart?.items || []
})

function statusText(status: string) {
  return { idle: '空闲', occupied: '就餐中', reserved: '已预约', ordering: '点餐中' }[status] || status
}

async function fetchTables() {
  try {
    const [zonesRes, tablesRes] = await Promise.all([
      tableApi.listZones(branchId.value),
      tableApi.listTables(branchId.value),
    ])
    zones.value = zonesRes.data
    tables.value = tablesRes.data
  } catch (e: unknown) {
    ElMessage.error('加载桌台失败')
  }
}

async function fetchProducts() {
  try {
    const { data } = await productApi.list(branchId.value)
    products.value = data.data
  } catch {
    ElMessage.error('加载商品失败')
  }
}

function handleTableSelect(table: Table) {
  selectedTable.value = table
  if (table.status !== 'idle') {
    cartStore.fetchCart(branchId.value, 'eat_in_hall')
  }
}

function startOrder() {
  router.push({
    name: 'tableCart',
    params: { branchId: branchId.value, tableId: selectedTable.value!.id },
  })
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

async function placeOrder() {
  try {
    await cartStore.placeCart(branchId.value, 'eat_in_hall', {
      table_id: selectedTable.value?.id,
    })
    ElMessage.success('下单成功')
    await fetchTables()
  } catch (e: unknown) {
    const err = e as { message?: string }
    ElMessage.error(err.message || '下单失败')
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
    ElMessageBox.confirm('确定退出登录?', '提示').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  } else if (command === 'settings') {
    router.push({ name: 'settings' })
  }
}

onMounted(() => {
  fetchTables()
  fetchProducts()
})
</script>
