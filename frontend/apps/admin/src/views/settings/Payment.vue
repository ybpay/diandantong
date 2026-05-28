<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">支付方式设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form :model="paymentForm" label-width="160px" class="max-w-2xl" v-loading="loading">
        <el-divider content-position="left">微信支付</el-divider>

        <el-form-item label="启用微信支付">
          <el-switch v-model="paymentForm.wechat_pay_enabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="微信支付商户号" v-if="paymentForm.wechat_pay_enabled">
          <el-input v-model="paymentForm.wechat_mch_id" placeholder="商户号" />
        </el-form-item>

        <el-divider content-position="left">支付宝</el-divider>

        <el-form-item label="启用支付宝">
          <el-switch v-model="paymentForm.alipay_enabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="支付宝AppID" v-if="paymentForm.alipay_enabled">
          <el-input v-model="paymentForm.alipay_app_id" placeholder="支付宝应用 AppID" />
        </el-form-item>

        <el-divider content-position="left">银行卡支付</el-divider>

        <el-form-item label="启用银行卡支付">
          <el-switch v-model="paymentForm.card_enabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { paymentApi } from '@diandantong/admin-api'

const loading = ref(false)
const saving = ref(false)

const paymentForm = reactive({
  wechat_pay_enabled: true,
  wechat_mch_id: '',
  alipay_enabled: true,
  alipay_app_id: '',
  card_enabled: false,
})

const fetchSettings = async () => {
  loading.value = true
  try {
    const { data } = await paymentApi.getSettings()
    const settings = (data as any)?.data || data
    if (settings) {
      paymentForm.wechat_pay_enabled = settings.wechat_pay_enabled ?? true
      paymentForm.wechat_mch_id = settings.wechat_mch_id ?? ''
      paymentForm.alipay_enabled = settings.alipay_enabled ?? true
      paymentForm.alipay_app_id = settings.alipay_app_id ?? ''
      paymentForm.card_enabled = settings.card_enabled ?? false
    }
  } catch {
    // Settings may not exist yet, use defaults
  } finally {
    loading.value = false
  }
}

const handleSave = async () => {
  saving.value = true
  try {
    await paymentApi.updateSettings({
      wechat_pay_enabled: paymentForm.wechat_pay_enabled,
      wechat_mch_id: paymentForm.wechat_mch_id,
      alipay_enabled: paymentForm.alipay_enabled,
      alipay_app_id: paymentForm.alipay_app_id,
      card_enabled: paymentForm.card_enabled,
    })
    ElMessage.success('支付设置已保存')
  } catch {
    ElMessage.error('保存失败，请重试')
  } finally {
    saving.value = false
  }
}

onMounted(fetchSettings)
</script>
