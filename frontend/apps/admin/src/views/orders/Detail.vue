<template>
  <div class="p-6 space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <el-button @click="$router.back()" :icon="ArrowLeft" text>返回</el-button>
        <h2 class="text-lg font-semibold">订单详情</h2>
        <el-tag :type="statusTag(order.status)" size="large">{{ order.statusText }}</el-tag>
      </div>
      <div class="flex gap-2">
        <el-button type="primary" v-if="order.status === 'pending'" @click="handleAccept">接单</el-button>
        <el-button type="warning" v-if="order.status === 'processing'" @click="handleComplete">完成订单</el-button>
        <el-button type="danger" v-if="['pending', 'processing'].includes(order.status)" @click="handleCancel">取消订单</el-button>
        <el-button @click="handlePrint">打印小票</el-button>
        <el-button @click="handleRefund" v-if="order.status === 'completed'">退款</el-button>
      </div>
    </div>

    <!-- Order Info Cards -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <!-- Basic Info -->
      <el-card shadow="hover">
        <template #header><span class="font-semibold">基本信息</span></template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="订单号">{{ order.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="订单类型">
            <el-tag size="small">{{ order.type }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="下单时间">{{ order.createdAt }}</el-descriptions-item>
          <el-descriptions-item label="支付方式">{{ order.payMethod }}</el-descriptions-item>
          <el-descriptions-item label="门店">{{ order.branchName }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ order.remark || '无' }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <!-- Customer / Delivery Info -->
      <el-card shadow="hover">
        <template #header><span class="font-semibold">{{ order.type === '外卖' ? '配送信息' : '客户信息' }}</span></template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="客户姓名">{{ order.customerName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ order.customerPhone }}</el-descriptions-item>
          <template v-if="order.type === '堂食'">
            <el-descriptions-item label="桌号">{{ order.tableNo }}号桌</el-descriptions-item>
            <el-descriptions-item label="用餐人数">{{ order.personCount }}人</el-descriptions-item>
          </template>
          <template v-if="order.type === '外卖'">
            <el-descriptions-item label="配送地址" :span="2">{{ order.deliveryAddress }}</el-descriptions-item>
            <el-descriptions-item label="骑手">{{ order.riderName || '待分配' }}</el-descriptions-item>
            <el-descriptions-item label="配送状态">{{ order.deliveryStatus }}</el-descriptions-item>
          </template>
        </el-descriptions>
      </el-card>
    </div>

    <!-- Line Items -->
    <el-card shadow="hover">
      <template #header><span class="font-semibold">订单明细</span></template>
      <el-table :data="order.items" stripe style="width: 100%">
        <el-table-column prop="name" label="菜品" min-width="200" />
        <el-table-column prop="specs" label="规格" width="120" />
        <el-table-column prop="price" label="单价" width="100">
          <template #default="{ row }">&yen;{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="quantity" label="数量" width="80" />
        <el-table-column prop="subtotal" label="小计" width="100">
          <template #default="{ row }">&yen;{{ row.subtotal }}</template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="120" />
      </el-table>
    </el-card>

    <!-- Payment Summary -->
    <el-card shadow="hover">
      <template #header><span class="font-semibold">支付信息</span></template>
      <div class="max-w-md ml-auto space-y-2">
        <div class="flex justify-between text-gray-600">
          <span>菜品合计</span>
          <span>&yen;{{ order.subtotal }}</span>
        </div>
        <div class="flex justify-between text-gray-600">
          <span>包装费</span>
          <span>&yen;{{ order.packingFee }}</span>
        </div>
        <div class="flex justify-between text-gray-600">
          <span>配送费</span>
          <span>&yen;{{ order.deliveryFee }}</span>
        </div>
        <div class="flex justify-between text-green-600" v-if="order.discount > 0">
          <span>优惠减免</span>
          <span>-&yen;{{ order.discount }}</span>
        </div>
        <el-divider />
        <div class="flex justify-between text-lg font-bold">
          <span>实付金额</span>
          <span class="text-red-500">&yen;{{ order.totalAmount }}</span>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'

const route = useRoute()

const order = ref({
  id: route.params.id || '1',
  orderNo: 'DD20260527001',
  type: '堂食',
  status: 'processing',
  statusText: '进行中',
  createdAt: '2026-05-27 11:30:00',
  payMethod: '微信支付',
  branchName: '总店（中心店）',
  remark: '不要辣',
  customerName: '张三',
  customerPhone: '138****1234',
  tableNo: 'A3',
  personCount: 4,
  deliveryAddress: '',
  riderName: '',
  deliveryStatus: '',
  subtotal: '138.00',
  packingFee: '0.00',
  deliveryFee: '0.00',
  discount: '10.00',
  totalAmount: '128.00',
  items: [
    { name: '宫保鸡丁', specs: '大份', price: '38.00', quantity: 1, subtotal: '38.00', remark: '' },
    { name: '糖醋排骨', specs: '大份', price: '48.00', quantity: 1, subtotal: '48.00', remark: '' },
    { name: '蛋炒饭', specs: '', price: '15.00', quantity: 2, subtotal: '30.00', remark: '' },
    { name: '酸辣汤', specs: '中份', price: '22.00', quantity: 1, subtotal: '22.00', remark: '不要辣' },
  ],
})

const statusTag = (s: string) => ({ pending: 'info', processing: 'warning', completed: 'success', cancelled: 'danger' }[s] ?? '')

const handleAccept = () => { ElMessage.success('已接单') }
const handleComplete = async () => {
  await ElMessageBox.confirm('确认完成该订单？', '提示')
  ElMessage.success('订单已完成')
}
const handleCancel = async () => {
  await ElMessageBox.confirm('确认取消该订单？此操作不可恢复。', '警告', { type: 'warning' })
  ElMessage.warning('订单已取消')
}
const handlePrint = () => { ElMessage.info('正在打印小票...') }
const handleRefund = async () => {
  await ElMessageBox.confirm('确认退款？金额将原路返回。', '退款确认', { type: 'warning' })
  ElMessage.success('退款申请已提交')
}
</script>
