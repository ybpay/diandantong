<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">VIP设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form ref="formRef" :model="settingsForm" label-width="160px" class="max-w-2xl">
        <el-divider content-position="left">基础设置</el-divider>

        <el-form-item label="启用VIP系统">
          <el-switch v-model="settingsForm.enabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="注册送积分">
          <el-input-number v-model="settingsForm.registerPoints" :min="0" />
          <span class="ml-2 text-gray-400">新会员注册赠送积分</span>
        </el-form-item>

        <el-form-item label="积分规则">
          <span class="mr-2">每消费</span>
          <el-input-number v-model="settingsForm.pointsPerYuan" :min="1" style="width: 100px" />
          <span class="ml-2">元获得1积分</span>
        </el-form-item>

        <el-divider content-position="left">积分兑换</el-divider>

        <el-form-item label="积分抵扣">
          <el-switch v-model="settingsForm.pointsDeductionEnabled" active-text="允许" inactive-text="禁止" />
        </el-form-item>

        <el-form-item label="抵扣比例" v-if="settingsForm.pointsDeductionEnabled">
          <span class="mr-2">每</span>
          <el-input-number v-model="settingsForm.deductionPoints" :min="1" style="width: 100px" />
          <span class="mx-2">积分抵扣</span>
          <el-input-number v-model="settingsForm.deductionAmount" :min="0.01" :precision="2" style="width: 100px" />
          <span class="ml-2">元</span>
        </el-form-item>

        <el-divider content-position="left">自动升级</el-divider>

        <el-form-item label="自动升级">
          <el-switch v-model="settingsForm.autoUpgrade" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="升级提醒">
          <el-switch v-model="settingsForm.upgradeNotification" active-text="发送" inactive-text="不发送" />
        </el-form-item>

        <el-divider content-position="left">会员卡设置</el-divider>

        <el-form-item label="会员卡前缀">
          <el-input v-model="settingsForm.cardPrefix" placeholder="如：VIP" style="width: 200px" />
        </el-form-item>

        <el-form-item label="卡号起始值">
          <el-input-number v-model="settingsForm.cardStartNumber" :min="1" style="width: 200px" />
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance } from 'element-plus'

const formRef = ref<FormInstance>()
const saving = ref(false)

const settingsForm = reactive({
  enabled: true,
  registerPoints: 100,
  pointsPerYuan: 10,
  pointsDeductionEnabled: true,
  deductionPoints: 100,
  deductionAmount: 1.00,
  autoUpgrade: true,
  upgradeNotification: true,
  cardPrefix: 'VIP',
  cardStartNumber: 10000,
})

const handleSave = () => {
  saving.value = true
  // TODO: call VIP settings API
  setTimeout(() => { saving.value = false; ElMessage.success('VIP设置已保存') }, 500)
}
</script>
