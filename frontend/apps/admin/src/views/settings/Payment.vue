<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">支付方式设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form :model="paymentForm" label-width="160px" class="max-w-2xl">
        <el-divider content-position="left">微信支付</el-divider>

        <el-form-item label="启用微信支付">
          <el-switch v-model="paymentForm.wechatEnabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="微信支付商户号" v-if="paymentForm.wechatEnabled">
          <el-input v-model="paymentForm.wechatMchId" placeholder="商户号" />
        </el-form-item>

        <el-divider content-position="left">支付宝</el-divider>

        <el-form-item label="启用支付宝">
          <el-switch v-model="paymentForm.alipayEnabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="支付宝AppID" v-if="paymentForm.alipayEnabled">
          <el-input v-model="paymentForm.alipayAppId" placeholder="支付宝应用 AppID" />
        </el-form-item>

        <el-divider content-position="left">现金支付</el-divider>

        <el-form-item label="启用现金支付">
          <el-switch v-model="paymentForm.cashEnabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-divider content-position="left">会员余额支付</el-divider>

        <el-form-item label="启用余额支付">
          <el-switch v-model="paymentForm.balanceEnabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-divider content-position="left">其他设置</el-divider>

        <el-form-item label="自动确认收款">
          <el-switch v-model="paymentForm.autoConfirm" />
          <span class="ml-2 text-gray-400">线上支付成功后自动确认</span>
        </el-form-item>

        <el-form-item label="支付超时时间">
          <el-input-number v-model="paymentForm.paymentTimeout" :min="5" :max="60" />
          <span class="ml-2 text-gray-400">分钟</span>
        </el-form-item>

        <el-form-item label="小票打印">
          <el-switch v-model="paymentForm.autoPrintOnPay" />
          <span class="ml-2 text-gray-400">支付成功后自动打印小票</span>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const saving = ref(false)

const paymentForm = reactive({
  wechatEnabled: true,
  wechatMchId: '',
  alipayEnabled: true,
  alipayAppId: '',
  cashEnabled: true,
  balanceEnabled: true,
  autoConfirm: true,
  paymentTimeout: 15,
  autoPrintOnPay: true,
})

const handleSave = () => {
  saving.value = true
  setTimeout(() => { saving.value = false; ElMessage.success('支付设置已保存') }, 500)
}
</script>
