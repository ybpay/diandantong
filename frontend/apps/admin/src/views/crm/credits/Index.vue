<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">积分设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form :model="settingsForm" label-width="160px" class="max-w-2xl">
        <el-divider content-position="left">积分获取</el-divider>

        <el-form-item label="启用积分系统">
          <el-switch v-model="settingsForm.enabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="消费获得积分">
          <span class="mr-2">每消费</span>
          <el-input-number v-model="settingsForm.yuanPerPoint" :min="1" style="width: 120px" />
          <span class="ml-2">元获得 1 积分</span>
        </el-form-item>

        <el-form-item label="评价获得积分">
          <el-input-number v-model="settingsForm.reviewPoints" :min="0" />
          <span class="ml-2 text-gray-400">每次评价获得</span>
        </el-form-item>

        <el-form-item label="分享获得积分">
          <el-input-number v-model="settingsForm.sharePoints" :min="0" />
          <span class="ml-2 text-gray-400">每次分享获得</span>
        </el-form-item>

        <el-divider content-position="left">积分使用</el-divider>

        <el-form-item label="积分抵扣">
          <el-switch v-model="settingsForm.deductionEnabled" />
        </el-form-item>

        <el-form-item label="抵扣比例" v-if="settingsForm.deductionEnabled">
          <span class="mr-2">每</span>
          <el-input-number v-model="settingsForm.pointsPerDeduction" :min="1" style="width: 120px" />
          <span class="mx-2">积分抵扣</span>
          <el-input-number v-model="settingsForm.deductionAmount" :min="0.01" :precision="2" style="width: 120px" />
          <span class="ml-2">元</span>
        </el-form-item>

        <el-form-item label="积分有效期">
          <el-select v-model="settingsForm.expiryType" class="w-48">
            <el-option label="永久有效" value="permanent" />
            <el-option label="1年" value="1year" />
            <el-option label="2年" value="2year" />
          </el-select>
        </el-form-item>

        <el-divider content-position="left">积分兑换商品</el-divider>

        <el-form-item label="启用积分商城">
          <el-switch v-model="settingsForm.shopEnabled" />
        </el-form-item>

        <el-form-item label="兑换操作人">
          <el-select v-model="settingsForm.exchangeOperator" class="w-48">
            <el-option label="用户自助" value="self" />
            <el-option label="需人工确认" value="manual" />
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
  yuanPerPoint: 10,
  reviewPoints: 20,
  sharePoints: 10,
  deductionEnabled: true,
  pointsPerDeduction: 100,
  deductionAmount: 1,
  expiryType: 'permanent',
  shopEnabled: false,
  exchangeOperator: 'self',
})

const handleSave = () => {
  saving.value = true
  setTimeout(() => { saving.value = false; ElMessage.success('积分设置已保存') }, 500)
}
</script>
