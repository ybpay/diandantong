<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">厨房设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form :model="form" label-width="160px" class="max-w-2xl" v-loading="loading">
        <el-divider content-position="left">出餐提醒</el-divider>

        <el-form-item label="超时预警时间">
          <el-input-number v-model="form.warning_wait_minitue" :min="1" :max="120" />
          <span class="ml-2 text-gray-400">分钟（订单等待超过此时长将预警提示）</span>
        </el-form-item>

      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { kitchenSettingApi } from '@diandantong/admin-api'

const loading = ref(false)
const saving = ref(false)

const form = reactive({
  warning_wait_minitue: 30,
})

const fetchSettings = async () => {
  loading.value = true
  try {
    const { data } = await kitchenSettingApi.get()
    const settings = (data as any)?.data || data
    if (settings) {
      form.warning_wait_minitue = settings.warning_wait_minitue || 30
    }
  } catch {
    // Kitchen setting may not exist yet, use defaults
  } finally {
    loading.value = false
  }
}

const handleSave = async () => {
  saving.value = true
  try {
    await kitchenSettingApi.update({
      warning_wait_minitue: form.warning_wait_minitue,
    })
    ElMessage.success('厨房设置已保存')
  } catch {
    ElMessage.error('保存失败，请重试')
  } finally {
    saving.value = false
  }
}

onMounted(fetchSettings)
</script>
