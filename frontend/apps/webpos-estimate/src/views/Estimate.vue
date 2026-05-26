<template>
  <PosLayout
    title="清台管理"
    :branch-name="authStore.currentBranch?.name"
    :branch-id="branchId"
    :user-name="authStore.userName"
    :show-notifications="true"
    @command="handleCommand"
  >
    <div class="p-6 h-full flex flex-col">
      <!-- Toolbar -->
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-3">
          <el-select v-model="selectedZoneId" placeholder="全部区域" clearable class="w-48" @change="handleZoneChange">
            <el-option v-for="zone in zones" :key="zone.id" :label="zone.name" :value="zone.id" />
          </el-select>
          <el-button :icon="Refresh" @click="fetchTables">刷新</el-button>
        </div>
        <div class="flex items-center gap-4 text-sm text-gray-500">
          <span>
            <span class="inline-block w-3 h-3 rounded-sm bg-green-100 border border-green-400 mr-1" />
            空闲 {{ idleCount }}
          </span>
          <span>
            <span class="inline-block w-3 h-3 rounded-sm bg-red-100 border border-red-400 mr-1" />
            占用 {{ occupiedCount }}
          </span>
        </div>
      </div>

      <!-- Table Grid -->
      <div class="flex-1 overflow-auto">
        <div v-if="loading && tables.length === 0" class="flex items-center justify-center h-64">
          <el-icon class="is-loading" :size="32"><Loading /></el-icon>
        </div>

        <div v-else class="grid grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 2xl:grid-cols-6 gap-4">
          <div
            v-for="table in displayTables"
            :key="table.id"
            class="rounded-xl border-2 p-4 transition-all cursor-pointer hover:shadow-md"
            :class="tableCardClass(table)"
          >
            <!-- Table header -->
            <div class="flex items-center justify-between mb-2">
              <h3 class="text-lg font-bold">{{ table.name }}</h3>
              <el-tag :type="statusTagType(table.status)" size="small">
                {{ statusLabel(table.status) }}
              </el-tag>
            </div>

            <div class="text-xs text-gray-500 mb-3">{{ table.seats }}人座</div>

            <!-- Occupied table details -->
            <template v-if="table.status === 'occupied' && table.current_order_id">
              <div v-if="tableOrders[table.id]" class="space-y-2 mb-3">
                <div class="text-xs text-gray-600">
                  <span class="text-gray-400">单号：</span>
                  {{ tableOrders[table.id].order_no }}
                </div>
                <div class="text-xs text-gray-600">
                  <span class="text-gray-400">就餐时间：</span>
                  {{ formatTime(tableOrders[table.id].created_at) }}
                </div>
                <div class="text-xs text-gray-600">
                  <span class="text-gray-400">已用：</span>
                  <span class="text-orange-500 font-medium">{{ waitTime(tableOrders[table.id].created_at) }}</span>
                </div>
                <div class="text-sm font-bold text-red-600">
                  {{ formatPrice(tableOrders[table.id].total_price) }}
                </div>
                <div v-if="tableOrders[table.id].line_items.length > 0" class="text-xs text-gray-400 truncate">
                  {{ tableOrders[table.id].line_items.map(i => `${i.product_name}x${i.quantity}`).join('、') }}
                </div>
              </div>
              <div v-else class="text-xs text-gray-400 mb-3">加载订单信息...</div>
            </template>

            <!-- Action button -->
            <el-button
              v-if="table.status === 'occupied'"
              type="primary"
              size="small"
              class="w-full"
              :loading="clearingTableId === table.id"
              @click="handleClearTable(table)"
            >
              清台结账
            </el-button>
            <div v-else class="text-center text-xs text-gray-400 py-2">
              空闲可用
            </div>
          </div>
        </div>

        <el-empty v-if="!loading && displayTables.length === 0" description="暂无桌台信息" />
      </div>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { Refresh, Loading } from '@element-plus/icons-vue'
import { PosLayout } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { tableApi, orderApi } from '@webpos/api'
import { useActionCable, formatPrice, formatTime, waitTime } from '@webpos/composables'
import type { Table, TableZone, Order } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const branchId = computed(() => Number(route.params.branchId))

// Data
const tables = ref<Table[]>([])
const zones = ref<TableZone[]>([])
const tableOrders = ref<Record<number, Order>>({})
const loading = ref(false)
const selectedZoneId = ref<number | null>(null)
const clearingTableId = ref<number | null>(null)

// WebSocket for real-time updates
const { connected, subscribe, unsubscribe, on } = useActionCable(
  `TablesChannel:${branchId.value}`
)

// Computed
const displayTables = computed(() => {
  if (!selectedZoneId.value) return tables.value
  return tables.value.filter((t) => t.zone_id === selectedZoneId.value)
})

const idleCount = computed(() => tables.value.filter((t) => t.status === 'idle').length)
const occupiedCount = computed(() => tables.value.filter((t) => t.status === 'occupied').length)

// Methods
function tableCardClass(table: Table) {
  switch (table.status) {
    case 'idle':
      return 'bg-green-50 border-green-300 hover:border-green-500'
    case 'occupied':
      return 'bg-red-50 border-red-300 hover:border-red-500'
    case 'reserved':
      return 'bg-yellow-50 border-yellow-300 hover:border-yellow-500'
    case 'ordering':
      return 'bg-blue-50 border-blue-300 hover:border-blue-500'
    default:
      return 'bg-gray-50 border-gray-300 hover:border-gray-500'
  }
}

function statusTagType(status: string) {
  switch (status) {
    case 'idle': return 'success'
    case 'occupied': return 'danger'
    case 'reserved': return 'warning'
    case 'ordering': return 'info'
    default: return 'info'
  }
}

function statusLabel(status: string) {
  switch (status) {
    case 'idle': return '空闲'
    case 'occupied': return '就餐中'
    case 'reserved': return '已预约'
    case 'ordering': return '点餐中'
    default: return '未知'
  }
}

function handleZoneChange() {
  // Filtering is handled by computed property
}

async function fetchTables() {
  loading.value = true
  try {
    const [zonesRes, tablesRes] = await Promise.all([
      tableApi.listZones(branchId.value),
      tableApi.listTables(branchId.value),
    ])
    zones.value = zonesRes.data
    tables.value = tablesRes.data

    // Fetch order details for occupied tables
    await fetchOccupiedOrders()
  } catch (e: unknown) {
    const err = e as { message?: string }
    ElMessage.error(err.message || '获取桌台信息失败')
  } finally {
    loading.value = false
  }
}

async function fetchOccupiedOrders() {
  const occupiedTables = tables.value.filter(
    (t) => t.status === 'occupied' && t.current_order_id
  )
  const promises = occupiedTables.map(async (table) => {
    try {
      const { data } = await orderApi.get(
        branchId.value,
        'eat_in_hall',
        table.current_order_id!
      )
      tableOrders.value[table.id] = data
    } catch {
      // Silently skip failed order fetches
    }
  })
  await Promise.allSettled(promises)
}

async function handleClearTable(table: Table) {
  const order = tableOrders.value[table.id]
  if (!order) {
    ElMessage.warning('订单信息加载中，请稍后再试')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定清台「${table.name}」？\n\n订单号：${order.order_no}\n金额：${formatPrice(order.total_price)}\n\n清台后将标记为已结账，桌台状态变为空闲。`,
      '确认清台',
      {
        confirmButtonText: '确认清台',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
  } catch {
    // User cancelled
    return
  }

  clearingTableId.value = table.id
  try {
    await orderApi.complete(branchId.value, 'eat_in_hall', order.id)
    ElMessage.success(`桌台「${table.name}」已清台`)
    await fetchTables()
  } catch (e: unknown) {
    const err = e as { message?: string }
    ElMessage.error(err.message || '清台失败')
  } finally {
    clearingTableId.value = null
  }
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?')
      .then(async () => {
        await authStore.logout()
        router.push({ name: 'login' })
      })
      .catch(() => {})
  } else if (command === 'settings') {
    ElMessage.info('设置功能开发中')
  }
}

// WebSocket message handler
function handleTableUpdate(data: unknown) {
  const update = data as { table_id?: number; status?: string }
  if (update.table_id) {
    // Refresh tables on any table status change
    fetchTables()
  }
}

// Lifecycle
onMounted(() => {
  fetchTables()
  subscribe()
  on('table_update', handleTableUpdate)
  on('estimate_clear', handleTableUpdate)
})

onUnmounted(() => {
  unsubscribe()
})
</script>
