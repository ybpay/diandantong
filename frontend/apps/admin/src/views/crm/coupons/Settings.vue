<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">优惠券设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form ref="formRef" :model="settingsForm" label-width="160px" class="max-w-2xl">
        <el-divider content-position="left">基础设置</el-divider>

        <el-form-item label="启用优惠券">
          <el-switch v-model="settingsForm.enabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="每人限领">
          <el-input-number v-model="settingsForm.perUserLimit" :min="1" />
          <span class="ml-2 text-gray-400">同一优惠券每人可领取次数</span>
        </el-form-item>

        <el-form-item label="是否可叠加">
          <el-switch v-model="settingsForm.stackable" active-text="可叠加使用" inactive-text="不可叠加" />
        </el-form-item>

        <el-divider content-position="left">领取设置</el-divider>

        <el-form-item label="领取渠道">
          <el-checkbox-group v-model="settingsForm.channels">
            <el-checkbox label="小程序" value="miniprogram" />
            <el-checkbox label="公众号" value="official_account" />
            <el-checkbox label="H5页面" value="h5" />
            <el-checkbox label="后台发放" value="admin" />
          </el-checkbox-group>
        </el-form-item>

        <el-form-item label="新用户自动发券">
          <el-switch v-model="settingsForm.autoIssueNewUser" />
        </el-form-item>

        <el-divider content-position="left">过期设置</el-divider>

        <el-form-item label="过期提醒">
          <el-switch v-model="settingsForm.expiryReminder" />
          <span class="ml-2 text-gray-400">过期前1天提醒用户</span>
        </el-form-item>

        <el-form-item label="过期后处理">
          <el-select v-model="settingsForm.expiredAction" class="w-48">
            <el-option label="自动作废" value="void" />
            <el-option label="保留记录" value="keep" />
          </el-select>
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
  perUserLimit: 3,
  stackable: false,
  channels: ['miniprogram', 'admin'],
  autoIssueNewUser: true,
  expiryReminder: true,
  expiredAction: 'void',
})

const handleSave = () => {
  saving.value = true
  setTimeout(() => { saving.value = false; ElMessage.success('优惠券设置已保存') }, 500)
}
</script>
