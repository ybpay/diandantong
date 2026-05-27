<template>
  <div class="min-h-screen bg-gray-50 pb-24">
    <van-nav-bar
      title="确认订单"
      left-text="返回"
      left-arrow
      @click-left="router.back()"
      fixed
      placeholder
    />

    <!-- Delivery Info -->
    <van-cell-group class="mt-2" title="就餐方式">
      <van-cell
        :title="orderType === 'eat_in' ? '堂食' : '外带'"
        is-link
        @click="showOrderTypePicker = true"
      />
      <van-cell
        v-if="orderType === 'eat_in'"
        title="桌号"
        :value="tableNumber || '请选择'"
        is-link
        @click="showTablePicker = true"
      />
      <van-cell
        v-else
        title="联系电话"
        :value="phone || '请输入'"
        is-link
        @click="showPhoneInput = true"
      />
    </van-cell-group>

    <!-- Items Summary -->
    <van-cell-group class="mt-2" title="订单明细">
      <van-cell
        v-for="item in cartStore.items"
        :key="`${item.productId}-${item.variants}`"
        :title="`${item.name}${item.variants ? ` (${item.variants})` : ''}`"
        :value="`x${item.quantity}`"
        :label="`¥${(item.price * item.quantity).toFixed(2)}`"
      />
    </van-cell-group>

    <!-- Coupon -->
    <van-cell-group class="mt-2">
      <van-cell title="优惠券" :value="selectedCoupon ? `-¥${selectedCoupon.discount}` : '无可用'" is-link />
      <van-cell title="备注" :value="remark || '点击填写'" is-link @click="showRemarkInput = true" />
    </van-cell-group>

    <!-- Payment Method -->
    <van-cell-group class="mt-2" title="支付方式">
      <van-radio-group v-model="paymentMethod">
        <van-cell title="微信支付" clickable @click="paymentMethod = 'wechat'">
          <template #right-icon>
            <van-radio name="wechat" />
          </template>
        </van-cell>
        <van-cell title="余额支付" clickable @click="paymentMethod = 'balance'">
          <template #right-icon>
            <van-radio name="balance" />
          </template>
        </van-cell>
      </van-radio-group>
    </van-cell-group>

    <!-- Submit -->
    <van-submit-bar
      :price="Math.round(orderTotal * 100)"
      button-text="提交订单"
      :loading="submitting"
      @submit="submitOrder"
    />

    <!-- Order Type Picker -->
    <van-action-sheet v-model:show="showOrderTypePicker" :actions="orderTypeActions" @select="onOrderTypeSelect" />

    <!-- Remark Input -->
    <van-dialog
      v-model:show="showRemarkInput"
      title="订单备注"
      show-cancel-button
      @confirm="remark = tempRemark"
    >
      <van-field v-model="tempRemark" placeholder="请输入备注信息" type="textarea" rows="3" />
    </van-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { useCartStore } from '@/stores/cart'
import { h5Client } from '@/api/client'

interface Coupon {
  id: number
  name: string
  discount: number
}

const router = useRouter()
const cartStore = useCartStore()

const orderType = ref('eat_in')
const tableNumber = ref('')
const phone = ref('')
const remark = ref('')
const tempRemark = ref('')
const paymentMethod = ref('wechat')
const selectedCoupon = ref<Coupon | null>(null)
const submitting = ref(false)
const showOrderTypePicker = ref(false)
const showTablePicker = ref(false)
const showPhoneInput = ref(false)
const showRemarkInput = ref(false)

const orderTotal = computed(() => {
  let total = cartStore.totalPrice
  if (selectedCoupon.value) {
    total -= selectedCoupon.value.discount
  }
  return Math.max(0, total)
})

const orderTypeActions = [
  { name: '堂食', value: 'eat_in' },
  { name: '外带', value: 'takeaway' },
]

function onOrderTypeSelect(action: any): void {
  orderType.value = action.value
  showOrderTypePicker.value = false
}

async function submitOrder(): Promise<void> {
  if (cartStore.items.length === 0) {
    showToast('购物车为空')
    return
  }

  submitting.value = true
  try {
    const { data } = await h5Client.post('/orders', {
      branch_id: cartStore.branchId,
      order_type: orderType.value,
      table_number: tableNumber.value || undefined,
      phone: phone.value || undefined,
      remark: remark.value || undefined,
      payment_method: paymentMethod.value,
      coupon_id: selectedCoupon.value?.id,
      items: cartStore.items.map((item) => ({
        product_id: item.productId,
        quantity: item.quantity,
        variants: item.variants,
        price: item.price,
      })),
    })
    cartStore.clear()
    router.replace(`/order/success?order_no=${data.order_no}`)
  } catch (e: any) {
    showToast(e.response?.data?.message || '下单失败')
  } finally {
    submitting.value = false
  }
}
</script>
