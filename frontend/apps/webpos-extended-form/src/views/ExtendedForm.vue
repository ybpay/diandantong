<template>
  <PosLayout
    title="扩展表单"
    :branch-name="authStore.currentBranch?.name"
    :branch-id="authStore.currentBranch?.id"
    :user-name="authStore.userName"
    @command="handleCommand"
  >
    <div class="extended-form p-6 max-w-3xl mx-auto">
      <el-card shadow="never">
        <template #header>
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-bold">客户信息采集</h2>
            <el-button text type="primary" @click="loadFormElements">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </div>
        </template>

        <!-- Loading state -->
        <div v-if="loading" class="flex justify-center py-12">
          <el-icon class="is-loading" :size="32"><Loading /></el-icon>
        </div>

        <!-- Empty state -->
        <el-empty v-else-if="formElements.length === 0" description="暂无表单字段" />

        <!-- Form -->
        <el-form
          v-else
          ref="formRef"
          :model="formData"
          :rules="formRules"
          label-width="100px"
          label-position="right"
          class="mt-4"
        >
          <el-form-item
            v-for="element in formElements"
            :key="element.id"
            :label="element.name"
            :prop="String(element.id)"
          >
            <!-- Text input -->
            <el-input
              v-if="element.field_type === 'text'"
              v-model="formData[String(element.id)]"
              :placeholder="`请输入${element.name}`"
              clearable
            />

            <!-- Number input -->
            <el-input-number
              v-else-if="element.field_type === 'number'"
              v-model="formData[String(element.id)]"
              :placeholder="`请输入${element.name}`"
              :controls="true"
              class="w-full"
            />

            <!-- Select dropdown -->
            <el-select
              v-else-if="element.field_type === 'select'"
              v-model="formData[String(element.id)]"
              :placeholder="`请选择${element.name}`"
              clearable
              class="w-full"
            >
              <el-option
                v-for="option in element.options"
                :key="option"
                :label="option"
                :value="option"
              />
            </el-select>

            <!-- Date picker -->
            <el-date-picker
              v-else-if="element.field_type === 'date'"
              v-model="formData[String(element.id)]"
              type="date"
              :placeholder="`请选择${element.name}`"
              value-format="YYYY-MM-DD"
              class="w-full"
            />

            <!-- Textarea -->
            <el-input
              v-else-if="element.field_type === 'textarea'"
              v-model="formData[String(element.id)]"
              type="textarea"
              :placeholder="`请输入${element.name}`"
              :rows="3"
            />
          </el-form-item>

          <el-form-item class="mt-6">
            <el-button type="primary" :loading="submitting" @click="handleSubmit">
              提交
            </el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <!-- Submitted results -->
      <el-card v-if="submittedData" shadow="never" class="mt-4">
        <template #header>
          <div class="flex items-center justify-between">
            <h3 class="font-bold">提交成功</h3>
            <el-tag type="success">已提交</el-tag>
          </div>
        </template>
        <el-descriptions :column="1" border>
          <el-descriptions-item
            v-for="element in formElements"
            :key="element.id"
            :label="element.name"
          >
            {{ formatFieldValue(element, submittedData[String(element.id)]) }}
          </el-descriptions-item>
        </el-descriptions>
      </el-card>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Refresh, Loading } from '@element-plus/icons-vue'
import { PosLayout } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { formElementApi } from '@webpos/api'
import client from '@webpos/api'
import type { FormElement, ExtendedFormData } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const formRef = ref()
const loading = ref(false)
const submitting = ref(false)
const formElements = ref<FormElement[]>([])
const submittedData = ref<ExtendedFormData | null>(null)

const formData = reactive<Record<string, string | number | boolean>>({})

const formRules = computed(() => {
  const rules: Record<string, Array<{ required: boolean; message: string; trigger: string }>> = {}
  for (const element of formElements.value) {
    if (element.required) {
      rules[String(element.id)] = [
        {
          required: true,
          message: `请填写${element.name}`,
          trigger: element.field_type === 'select' ? 'change' : 'blur',
        },
      ]
    }
  }
  return rules
})

async function loadFormElements() {
  const branchId = Number(route.params.branchId)
  if (!branchId) return

  loading.value = true
  try {
    const { data } = await formElementApi.list(branchId)
    formElements.value = data
    initFormData()
    submittedData.value = null
  } catch (e: unknown) {
    const err = e as { message?: string }
    ElMessage.error(err.message || '加载表单字段失败')
  } finally {
    loading.value = false
  }
}

function initFormData() {
  // Clear existing keys
  for (const key of Object.keys(formData)) {
    delete formData[key]
  }
  // Initialize each field with appropriate default
  for (const element of formElements.value) {
    const key = String(element.id)
    if (element.field_type === 'number') {
      formData[key] = 0
    } else {
      formData[key] = ''
    }
  }
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) {
    ElMessage.warning('请填写所有必填项')
    return
  }

  submitting.value = true
  try {
    const branchId = Number(route.params.branchId)
    await client.post(`/branches/${branchId}/extended_form_submissions`, {
      extended_form: { ...formData },
    })
    ElMessage.success('提交成功')
    submittedData.value = { ...formData }
  } catch (e: unknown) {
    const err = e as { message?: string }
    ElMessage.error(err.message || '提交失败')
  } finally {
    submitting.value = false
  }
}

function handleReset() {
  initFormData()
  formRef.value?.clearValidate()
  submittedData.value = null
}

function formatFieldValue(element: FormElement, value: string | number | boolean | undefined): string {
  if (value === undefined || value === null || value === '') return '-'
  if (element.field_type === 'date' && typeof value === 'string') {
    return value
  }
  return String(value)
}

function handleCommand(command: string) {
  if (command === 'logout') {
    authStore.logout()
    router.push({ name: 'login' })
  } else if (command === 'settings') {
    // Placeholder for settings navigation
  }
}

onMounted(() => {
  loadFormElements()
})
</script>
