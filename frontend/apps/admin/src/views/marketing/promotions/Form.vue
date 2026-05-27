<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">{{ isEdit ? '编辑促销活动' : '创建促销活动' }}</span>
          <el-button @click="$router.back()">返回</el-button>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="promoForm"
        :rules="rules"
        label-width="120px"
        class="max-w-2xl"
      >
        <el-form-item label="活动名称" prop="name">
          <el-input v-model="promoForm.name" placeholder="请输入活动名称" />
        </el-form-item>

        <el-form-item label="活动类型" prop="type">
          <el-select v-model="promoForm.type" class="w-full">
            <el-option label="满减" value="满减" />
            <el-option label="折扣" value="折扣" />
            <el-option label="赠品" value="赠品" />
            <el-option label="限时特价" value="限时特价" />
          </el-select>
        </el-form-item>

        <el-form-item label="活动时间" prop="dateRange">
          <el-date-picker v-model="promoForm.dateRange" type="datetimerange" range-separator="至" start-placeholder="开始时间" end-placeholder="结束时间" class="w-full" />
        </el-form-item>

        <el-form-item label="优惠规则" prop="rules">
          <div class="space-y-2 w-full">
            <div v-for="(rule, index) in promoForm.rules" :key="index" class="flex items-center gap-2">
              <span class="text-gray-500 whitespace-nowrap">满</span>
              <el-input-number v-model="rule.threshold" :min="0" :precision="2" style="width: 140px" />
              <span class="text-gray-500 whitespace-nowrap">减</span>
              <el-input-number v-model="rule.discount" :min="0" :precision="2" style="width: 140px" />
              <el-button text type="danger" @click="promoForm.rules.splice(index, 1)" :disabled="promoForm.rules.length <= 1">删除</el-button>
            </div>
            <el-button text type="primary" @click="promoForm.rules.push({ threshold: 0, discount: 0 })">+ 添加规则阶梯</el-button>
          </div>
        </el-form-item>

        <el-form-item label="适用门店">
          <el-select v-model="promoForm.branchIds" multiple placeholder="全部门店" class="w-full">
            <el-option label="总店" :value="1" />
            <el-option label="城西分店" :value="2" />
            <el-option label="滨江分店" :value="3" />
          </el-select>
        </el-form-item>

        <el-form-item label="适用商品">
          <el-select v-model="promoForm.productScope" class="w-full">
            <el-option label="全部商品" value="all" />
            <el-option label="指定分类" value="category" />
            <el-option label="指定商品" value="product" />
          </el-select>
        </el-form-item>

        <el-form-item label="活动描述">
          <el-input v-model="promoForm.description" type="textarea" :rows="3" placeholder="活动描述" />
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

const promoForm = reactive({
  name: '',
  type: '满减',
  dateRange: null as any,
  rules: [{ threshold: 100, discount: 10 }],
  branchIds: [] as number[],
  productScope: 'all',
  description: '',
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入活动名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择活动类型', trigger: 'change' }],
  dateRange: [{ required: true, message: '请选择活动时间', trigger: 'change' }],
}

const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => {
    if (!valid) return
    saving.value = true
    setTimeout(() => { saving.value = false; ElMessage.success(isEdit.value ? '活动已更新' : '活动已创建') }, 500)
  })
}
</script>
