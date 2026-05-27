<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">充值设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form :model="settingsForm" label-width="160px" class="max-w-2xl">
        <el-divider content-position="left">基础设置</el-divider>

        <el-form-item label="启用充值功能">
          <el-switch v-model="settingsForm.enabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="最低充值金额">
          <el-input-number v-model="settingsForm.minAmount" :min="1" :precision="2" />
          <span class="ml-2 text-gray-400">元</span>
        </el-form-item>

        <el-form-item label="最高充值金额">
          <el-input-number v-model="settingsForm.maxAmount" :min="100" :precision="2" />
          <span class="ml-2 text-gray-400">元</span>
        </el-form-item>

        <el-divider content-position="left">支付方式</el-divider>

        <el-form-item label="支持的支付方式">
          <el-checkbox-group v-model="settingsForm.payMethods">
            <el-checkbox label="微信支付" value="wechat" />
            <el-checkbox label="支付宝" value="alipay" />
            <el-checkbox label="现金" value="cash" />
            <el-checkbox label="银行卡" value="card" />
          </el-checkbox-group>
        </el-form-item>

        <el-divider content-position="left">通知设置</el-divider>

        <el-form-item label="充值成功通知">
          <el-switch v-model="settingsForm.successNotification" />
        </el-form-item>

        <el-form-item label="余额不足提醒">
          <el-switch v-model="settingsForm.lowBalanceReminder" />
        </el-form-item>

        <el-form-item label="提醒阈值" v-if="settingsForm.lowBalanceReminder">
          <el-input-number v-model="settingsForm.reminderThreshold" :min="0" />
          <span class="ml-2 text-gray-400">元以下时提醒</span>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const saving = ref(false)

const settingsForm = reactive({
  enabled: true,
  minAmount: 50,
  maxAmount: 10000,
  payMethods: ['wechat', 'alipay', 'cash'],
  successNotification: true,
  lowBalanceReminder: true,
  reminderThreshold: 50,
})

const handleSave = () => {
  saving.value = true
  setTimeout(() => { saving.value = false; ElMessage.success('充值设置已保存') }, 500)
}
</script>
