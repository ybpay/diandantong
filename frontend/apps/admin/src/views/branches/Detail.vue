<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">{{ isEdit ? '编辑门店' : '新增门店' }}</span>
          <el-button @click="$router.back()">返回</el-button>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="branchForm"
        :rules="rules"
        label-width="120px"
        class="max-w-2xl"
      >
        <el-form-item label="门店名称" prop="name">
          <el-input v-model="branchForm.name" placeholder="请输入门店名称" />
        </el-form-item>

        <el-form-item label="门店地址" prop="address">
          <el-input v-model="branchForm.address" placeholder="请输入门店地址" />
        </el-form-item>

        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="branchForm.phone" placeholder="请输入联系电话" />
        </el-form-item>

        <el-form-item label="营业时间">
          <div class="flex items-center gap-2">
            <el-time-select v-model="branchForm.openTime" placeholder="开始时间" :start="'00:00'" :step="'00:30'" :end="'23:30'" />
            <span class="text-gray-400">至</span>
            <el-time-select v-model="branchForm.closeTime" placeholder="结束时间" :start="'00:00'" :step="'00:30'" :end="'23:30'" />
          </div>
        </el-form-item>

        <el-form-item label="门店描述">
          <el-input v-model="branchForm.description" type="textarea" :rows="3" placeholder="请输入门店描述" />
        </el-form-item>

        <el-form-item label="门店状态">
          <el-switch v-model="branchForm.active" active-text="营业中" inactive-text="已关闭" />
        </el-form-item>

        <el-form-item label="排序权重">
          <el-input-number v-model="branchForm.sortOrder" :min="0" :max="999" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="saving" @click="handleSave">保存</el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const route = useRoute()
const formRef = ref<FormInstance>()
const saving = ref(false)

const isEdit = computed(() => !!route.params.id)

const branchForm = reactive({
  name: '',
  address: '',
  phone: '',
  openTime: '09:00',
  closeTime: '22:00',
  description: '',
  active: true,
  sortOrder: 0,
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入门店名称', trigger: 'blur' }],
  address: [{ required: true, message: '请输入门店地址', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }],
}

const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => {
    if (!valid) return
    saving.value = true
    // TODO: call branch create/update API
    setTimeout(() => {
      saving.value = false
      ElMessage.success(isEdit.value ? '门店已更新' : '门店已创建')
    }, 500)
  })
}
</script>
