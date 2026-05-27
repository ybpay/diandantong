<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">店铺设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="shopForm"
        :rules="rules"
        label-width="120px"
        class="max-w-2xl"
      >
        <el-form-item label="店铺名称" prop="name">
          <el-input v-model="shopForm.name" placeholder="请输入店铺名称" />
        </el-form-item>

        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="shopForm.phone" placeholder="请输入联系电话" />
        </el-form-item>

        <el-form-item label="店铺地址" prop="address">
          <el-input v-model="shopForm.address" type="textarea" :rows="2" placeholder="请输入店铺地址" />
        </el-form-item>

        <el-form-item label="营业时间" prop="businessHoursStart">
          <div class="flex items-center gap-2">
            <el-time-select v-model="shopForm.businessHoursStart" placeholder="开始时间" :start="'00:00'" :step="'00:30'" :end="'23:30'" />
            <span class="text-gray-400">至</span>
            <el-time-select v-model="shopForm.businessHoursEnd" placeholder="结束时间" :start="'00:00'" :step="'00:30'" :end="'23:30'" />
          </div>
        </el-form-item>

        <el-form-item label="店铺简介" prop="description">
          <el-input v-model="shopForm.description" type="textarea" :rows="4" placeholder="请输入店铺简介" />
        </el-form-item>

        <el-form-item label="店铺Logo">
          <el-upload
            action="#"
            :auto-upload="false"
            :show-file-list="false"
            accept="image/*"
          >
            <el-button>选择图片</el-button>
          </el-upload>
        </el-form-item>

        <el-form-item label="通知手机号" prop="notificationPhone">
          <el-input v-model="shopForm.notificationPhone" placeholder="接收订单通知的手机号" />
        </el-form-item>

        <el-form-item label="打印小票">
          <el-switch v-model="shopForm.autoPrint" active-text="自动打印" />
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const formRef = ref<FormInstance>()
const saving = ref(false)

const shopForm = reactive({
  name: '',
  phone: '',
  address: '',
  businessHoursStart: '09:00',
  businessHoursEnd: '22:00',
  description: '',
  notificationPhone: '',
  autoPrint: true,
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入店铺名称', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }],
}

const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => {
    if (!valid) return
    saving.value = true
    // TODO: call shop API
    setTimeout(() => {
      saving.value = false
      ElMessage.success('店铺设置已保存')
    }, 500)
  })
}
</script>
