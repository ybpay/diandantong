<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-xl font-bold text-gray-800">新建商户</h2>
      <el-button @click="router.back()">返回</el-button>
    </div>

    <el-card>
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="120px"
        label-position="right"
      >
        <el-divider content-position="left">基本信息</el-divider>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="商户名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入商户名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系人" prop="contact_name">
              <el-input v-model="form.contact_name" placeholder="请输入联系人" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="联系电话" prop="phone">
              <el-input v-model="form.phone" placeholder="请输入联系电话" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="登录邮箱" prop="email">
              <el-input v-model="form.email" placeholder="请输入登录邮箱" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="登录密码" prop="password">
              <el-input v-model="form.password" type="password" placeholder="请输入登录密码" show-password />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="确认密码" prop="password_confirmation">
              <el-input v-model="form.password_confirmation" type="password" placeholder="请确认密码" show-password />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入地址" />
        </el-form-item>

        <el-divider content-position="left">套餐信息</el-divider>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="套餐" prop="plan_id">
              <el-select v-model="form.plan_id" placeholder="请选择套餐" class="w-full">
                <el-option
                  v-for="plan in plans"
                  :key="plan.id"
                  :label="plan.name"
                  :value="plan.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="有效期(天)" prop="duration_days">
              <el-input-number v-model="form.duration_days" :min="1" :max="3650" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="备注信息" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">
            创建商户
          </el-button>
          <el-button @click="router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { agentClient } from '@/api/client'

interface Plan {
  id: number
  name: string
}

const router = useRouter()
const formRef = ref<FormInstance>()
const submitting = ref(false)
const plans = ref<Plan[]>([])

const form = reactive({
  name: '',
  contact_name: '',
  phone: '',
  email: '',
  password: '',
  password_confirmation: '',
  address: '',
  plan_id: null as number | null,
  duration_days: 365,
  remark: '',
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入商户名称', trigger: 'blur' }],
  contact_name: [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' },
  ],
  password_confirmation: [
    { required: true, message: '请确认密码', trigger: 'blur' },
  ],
  plan_id: [{ required: true, message: '请选择套餐', trigger: 'change' }],
  duration_days: [{ required: true, message: '请输入有效期', trigger: 'blur' }],
}

async function handleSubmit(): Promise<void> {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  if (form.password !== form.password_confirmation) {
    ElMessage.error('两次密码不一致')
    return
  }

  submitting.value = true
  try {
    const { data } = await agentClient.post('/merchants', {
      name: form.name,
      contact_name: form.contact_name,
      phone: form.phone,
      email: form.email,
      password: form.password,
      address: form.address,
      plan_id: form.plan_id,
      duration_days: form.duration_days,
      remark: form.remark,
    })
    ElMessage.success('商户创建成功')
    router.push(`/merchants/${data.id}`)
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '创建失败')
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  try {
    const { data } = await agentClient.get('/plans')
    plans.value = data
  } catch {
    // Use empty list
  }
})
</script>
