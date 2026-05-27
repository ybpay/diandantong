<template>
  <PosLayout title="桌台订单" :branch-name="authStore.currentBranch?.name" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-bold">订单详情</h3>
        <el-button @click="router.back()">返回</el-button>
      </div>
      <el-table v-if="order" :data="order.line_items" stripe>
        <el-table-column prop="product_name" label="商品" />
        <el-table-column prop="quantity" label="数量" width="80" />
        <el-table-column label="单价" width="100">
          <template #default="{ row }">{{ formatPrice(row.price) }}</template>
        </el-table-column>
        <el-table-column label="小计" width="100">
          <template #default="{ row }">{{ formatPrice(row.price * row.quantity) }}</template>
        </el-table-column>
        <el-table-column prop="note" label="备注" width="150" />
      </el-table>
      <div v-else class="text-center text-gray-400 py-8">加载中...</div>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore, useOrderStore } from '@webpos/stores'
import { formatPrice } from '@webpos/composables'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const orderStore = useOrderStore()

const branchId = computed(() => Number(route.params.branchId))
const orderId = computed(() => Number(route.params.orderId))
const order = computed(() => orderStore.currentOrder)

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}

onMounted(async () => {
  if (orderId.value) {
    await orderStore.fetchOrder(branchId.value, 'eat_in_hall', orderId.value)
  }
})
</script>
