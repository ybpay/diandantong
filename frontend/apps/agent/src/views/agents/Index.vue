<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-xl font-bold text-gray-800">子代理管理</h2>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon class="mr-1"><Plus /></el-icon>
        添加子代理
      </el-button>
    </div>

    <el-card>
      <el-table :data="subAgents" stripe v-loading="loading">
        <el-table-column prop="name" label="代理名称" min-width="120" />
        <el-table-column prop="email" label="邮箱" width="200" />
        <el-table-column prop="phone" label="联系电话" width="140" />
        <el-table-column prop="merchant_count" label="商户数" width="100" />
        <el-table-column prop="commission_rate" label="佣金比例" width="100">
          <template #default="{ row }">
            {{ (row.commission_rate * 100).toFixed(1) }}%
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'" size="small">
              {{ row.status === 'active' ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="180" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button
              text
              :type="row.status === 'active' ? 'danger' : 'success'"
              @click="handleToggleStatus(row)"
            >
              {{ row.status === 'active' ? '停用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Create/Edit Dialog -->
    <el-dialog v-model="showCreateDialog" :title="editingAgent ? '编辑子代理' : '添加子代理'" width="500px">
      <el-form ref="agentFormRef" :model="agentForm" :rules="agentRules" label-width="100px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="agentForm.name" placeholder="代理名称" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="agentForm.email" placeholder="登录邮箱" :disabled="!!editingAgent" />
        </el-form-item>
        <el-form-item v-if="!editingAgent" label="密码" prop="password">
          <el-input v-model="agentForm.password" type="password" placeholder="登录密码" show-password />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="agentForm.phone" placeholder="联系电话" />
        </el-form-item>
        <el-form-item label="佣金比例" prop="commission_rate">
          <el-input-number
            v-model="agentForm.commission_rate"
            :min="0"
            :max="100"
            :precision="1"
            :step="0.5"
          />
          <span class="ml-2 text-gray-500">%</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          {{ editingAgent ? '保存' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { agentClient } from '@/api/client'

interface SubAgent {
  id: number
  name: string
  email: string
  phone: string
  merchant_count: number
  commission_rate: number
  status: string
  created_at: string
}

const loading = ref(false)
const submitting = ref(false)
const subAgents = ref<SubAgent[]>([])
const showCreateDialog = ref(false)
const editingAgent = ref<SubAgent | null>(null)
const agentFormRef = ref<FormInstance>()

const agentForm = reactive({
  name: '',
  email: '',
  password: '',
  phone: '',
  commission_rate: 10,
})

const agentRules: FormRules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' },
  ],
}

async function fetchSubAgents(): Promise<void> {
  loading.value = true
  try {
    const { data } = await agentClient.get('/agents')
    subAgents.value = data
  } catch {
    // Use empty list
  } finally {
    loading.value = false
  }
}

function handleEdit(agent: SubAgent): void {
  editingAgent.value = agent
  agentForm.name = agent.name
  agentForm.email = agent.email
  agentForm.phone = agent.phone
  agentForm.commission_rate = agent.commission_rate * 100
  agentForm.password = ''
  showCreateDialog.value = true
}

async function handleSubmit(): Promise<void> {
  const valid = await agentFormRef.value?.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    if (editingAgent.value) {
      await agentClient.put(`/agents/${editingAgent.value.id}`, {
        name: agentForm.name,
        phone: agentForm.phone,
        commission_rate: agentForm.commission_rate / 100,
      })
      ElMessage.success('更新成功')
    } else {
      await agentClient.post('/agents', {
        name: agentForm.name,
        email: agentForm.email,
        password: agentForm.password,
        phone: agentForm.phone,
        commission_rate: agentForm.commission_rate / 100,
      })
      ElMessage.success('创建成功')
    }
    showCreateDialog.value = false
    editingAgent.value = null
    fetchSubAgents()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

async function handleToggleStatus(agent: SubAgent): Promise<void> {
  const action = agent.status === 'active' ? '停用' : '启用'
  try {
    await ElMessageBox.confirm(`确定要${action}该代理吗？`, `确认${action}`)
    await agentClient.put(`/agents/${agent.id}`, {
      status: agent.status === 'active' ? 'inactive' : 'active',
    })
    ElMessage.success(`已${action}`)
    fetchSubAgents()
  } catch {
    // User cancelled
  }
}

onMounted(() => {
  fetchSubAgents()
})
</script>
