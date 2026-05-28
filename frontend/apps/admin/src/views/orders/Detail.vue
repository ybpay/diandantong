<template>
  <div class="p-6 space-y-4" v-loading="loading">
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <el-button @click="$router.back()" :icon="ArrowLeft" text>返回</el-button>
        <h2 class="text-lg font-semibold">订单详情</h2>
        <el-tag v-if="order" :type="statusTagType(order.status)" size="large">{{ statusText(order.status) }}</el-tag>
      </div>
      <div v-if="order" class="flex gap-2">
        <el-button type="primary" v-if="order.status === 'pending'" @click="handleConfirm">确认</el-button>
        <el-button type="warning" v-if="order.status === 'confirmed'" @click="handleComplete">完成订单</el-button>
        <el-button type="danger" v-if="['pending', 'confirmed'].includes(order.status)" @click="handleCancel">取消订单</el-button>
        <el-button @click="handlePrint">打印小票</el-button>
      </div>
    </div>

    <template v-if="order">
      <!-- Order Info Cards -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <el-card shadow="hover">
          <template #header><span class="font-semibold">基本信息</span></template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="订单号">{{ order.order_no }}</el-descriptions-item>
            <el-descriptions-item label="订单类型">
              <el-tag size="small">{{ orderTypeLabel(order.order_type) }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="下单时间">{{ formatTime(order.placed_at || order.created_at) }}</el-descriptions-item>
            <el-descriptions-item label="完成时间">{{ order.completed_at ? formatTime(order.completed_at) : '-' }}</el-descriptions-item>
            <el-descriptions-item label="备注" :span="2">{{ order.note || '无' }}</el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- Type-specific info -->
        <el-card shadow="hover">
          <template #header><span class="font-semibold">{{ typeInfoTitle }}</span></template>
          <el-descriptions :column="2" border>
            <!-- Eat-in-hall -->
            <template v-if="order.order_type === 'eat_in_hall'">
              <el-descriptions-item label="桌号">{{ order.table_name || '-' }}号桌</el-descriptions-item>
              <el-descriptions-item label="用餐人数">{{ order.guest_num || '-' }}人</el-descriptions-item>
            </template>
            <!-- Delivery -->
            <template v-else-if="order.order_type === 'delivery'">
              <el-descriptions-item label="配送地址" :span="2">{{ order.delivery_address || '-' }}</el-descriptions-item>
              <el-descriptions-item label="骑手">{{ order.delivery_man_name || '待分配' }}</el-descriptions-item>
              <el-descriptions-item label="配送状态">{{ deliveryStatusText }}</el-descriptions-item>
            </template>
            <!-- Fast food -->
            <template v-else-if="order.order_type === 'fast_food'">
              <el-descriptions-item label="取餐码">
                <span class="font-bold text-orange-500 text-lg">{{ order.take_no || '-' }}</span>
              </el-descriptions-item>
            </template>
            <!-- Groupon -->
            <template v-else-if="order.order_type === 'groupon'">
              <el-descriptions-item label="券码">{{ order.groupon_code || '-' }}</el-descriptions-item>
              <el-descriptions-item label="平台">{{ order.groupon_platform || '-' }}</el-descriptions-item>
            </template>
            <!-- Reservation -->
            <template v-else-if="order.order_type === 'reservation'">
              <el-descriptions-item label="预约时间">{{ order.reserved_at ? formatTime(order.reserved_at) : '-' }}</el-descriptions-item>
              <el-descriptions-item label="人数">{{ order.person_count || '-' }}人</el-descriptions-item>
              <el-descriptions-item label="联系人">{{ order.customer_name || '-' }}</el-descriptions-item>
              <el-descriptions-item label="电话">{{ order.customer_phone || '-' }}</el-descriptions-item>
              <el-descriptions-item label="桌号">{{ order.table_name ? `${order.table_name}号桌` : '未排桌' }}</el-descriptions-item>
            </template>
            <!-- Recharge -->
            <template v-else-if="order.order_type === 'recharge'">
              <el-descriptions-item label="会员">{{ order.vip_name || '-' }}</el-descriptions-item>
              <el-descriptions-item label="手机号">{{ order.vip_phone || '-' }}</el-descriptions-item>
              <el-descriptions-item label="充值金额">&yen;{{ order.recharge_amount || '0.00' }}</el-descriptions-item>
              <el-descriptions-item label="赠送金额"><span class="text-red-500">+&yen;{{ order.bonus_amount || '0.00' }}</span></el-descriptions-item>
            </template>
            <!-- Payment -->
            <template v-else-if="order.order_type === 'payment'">
              <el-descriptions-item label="关联订单">{{ order.related_order_no || '-' }}</el-descriptions-item>
              <el-descriptions-item label="操作人">{{ order.operator_name || '-' }}</el-descriptions-item>
            </template>
          </el-descriptions>
        </el-card>
      </div>

      <!-- Line Items -->
      <el-card v-if="order.line_items?.length" shadow="hover">
        <template #header><span class="font-semibold">订单明细</span></template>
        <el-table :data="order.line_items" stripe style="width: 100%">
          <el-table-column prop="product_name" label="菜品" min-width="200" />
          <el-table-column prop="variant_name" label="规格" width="120" />
          <el-table-column label="单价" width="100">
            <template #default="{ row }">&yen;{{ row.price }}</template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="80" />
          <el-table-column label="小计" width="100">
            <template #default="{ row }">&yen;{{ (row.price * row.quantity).toFixed(2) }}</template>
          </el-table-column>
          <el-table-column prop="note" label="备注" min-width="120" />
        </el-table>
      </el-card>

      <!-- Payment Summary -->
      <el-card shadow="hover">
        <template #header><span class="font-semibold">支付信息</span></template>
        <div class="max-w-md ml-auto space-y-2">
          <div class="flex justify-between text-gray-600">
            <span>原价</span>
            <span>&yen;{{ order.original_price?.toFixed(2) || '0.00' }}</span>
          </div>
          <div class="flex justify-between text-green-600" v-if="(order.discount_amount ?? 0) > 0">
            <span>优惠减免</span>
            <span>-&yen;{{ order.discount_amount?.toFixed(2) }}</span>
          </div>
          <el-divider />
          <div class="flex justify-between text-lg font-bold">
            <span>实付金额</span>
            <span class="text-red-500">&yen;{{ order.total_amount?.toFixed(2) || '0.00' }}</span>
          </div>

          <!-- Pay Items -->
          <template v-if="order.pay_items?.length">
            <el-divider />
            <div class="text-sm text-gray-500">支付明细</div>
            <div v-for="item in order.pay_items" :key="item.id" class="flex justify-between text-gray-600">
              <span>{{ payMethodLabel(item.payment_method) }}</span>
              <span>&yen;{{ item.amount?.toFixed(2) }}</span>
            </div>
          </template>
        </div>
      </el-card>
    </template>

    <el-empty v-else-if="!loading" description="订单不存在" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import { orderApi } from '@diandantong/admin-api'
import type { AdminOrder, OrderType, PaymentMethod } from '@diandantong/admin-types'

const route = useRoute()
const loading = ref(false)
const order = ref<AdminOrder | null>(null)

const orderTypeLabel = (t: OrderType) => {
  const map: Record<OrderType, string> = {
    eat_in_hall: '堂食', delivery: '外卖', fast_food: '快餐',
    groupon: '团购', reservation: '预约', recharge: '充值', payment: '代收款',
  }
  return map[t] ?? t
}

const statusTagType = (s: string) => {
  const map: Record<string, string> = { pending: 'info', confirmed: 'warning', completed: 'success', cancelled: 'danger' }
  return map[s] ?? ''
}

const statusText = (s: string) => {
  const map: Record<string, string> = { pending: '待确认', confirmed: '已确认', completed: '已完成', cancelled: '已取消' }
  return map[s] ?? s
}

const payMethodLabel = (m?: PaymentMethod | string) => {
  const map: Record<string, string> = { cash: '现金', wechat: '微信', alipay: '支付宝', card: '银行卡', vip_balance: '会员余额', credits: '积分', mixed: '混合' }
  return map[m ?? ''] ?? m ?? '-'
}

const typeInfoTitle = computed(() => {
  if (!order.value) return ''
  const map: Record<OrderType, string> = {
    eat_in_hall: '用餐信息', delivery: '配送信息', fast_food: '取餐信息',
    groupon: '团购信息', reservation: '预约信息', recharge: '充值信息', payment: '收款信息',
  }
  return map[order.value.order_type] ?? '订单信息'
})

const deliveryStatusText = computed(() => {
  if (!order.value) return ''
  const map: Record<string, string> = { pending: '待接单', confirmed: '备餐中', delivering: '配送中', completed: '已送达', cancelled: '已取消' }
  return map[order.value.status] ?? order.value.status
})

const formatTime = (t: string) => {
  if (!t) return ''
  return new Date(t).toLocaleString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' })
}

async function fetchOrder() {
  const id = route.params.id as string
  if (!id) return
  loading.value = true
  try {
    const { data } = await orderApi.get(Number(id))
    order.value = data
  } catch (e: any) {
    ElMessage.error(e.message || '获取订单详情失败')
  } finally {
    loading.value = false
  }
}

async function handleConfirm() {
  if (!order.value) return
  try {
    const { data } = await orderApi.confirm(order.value.id)
    order.value = data
    ElMessage.success('已确认')
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

async function handleComplete() {
  if (!order.value) return
  try {
    await ElMessageBox.confirm('确认完成该订单？', '提示')
    const { data } = await orderApi.complete(order.value.id)
    order.value = data
    ElMessage.success('订单已完成')
  } catch { /* cancelled */ }
}

async function handleCancel() {
  if (!order.value) return
  try {
    await ElMessageBox.confirm('确认取消该订单？此操作不可恢复。', '警告', { type: 'warning' })
    const { data } = await orderApi.cancel(order.value.id)
    order.value = data
    ElMessage.warning('订单已取消')
  } catch { /* cancelled */ }
}

const handlePrint = () => { ElMessage.info('正在打印小票...') }

onMounted(fetchOrder)
</script>
