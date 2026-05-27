<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-xl font-bold text-gray-800">品牌配置</h2>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon class="mr-1"><Plus /></el-icon>
        新建品牌
      </el-button>
    </div>

    <el-card>
      <el-table :data="brands" stripe v-loading="loading">
        <el-table-column prop="name" label="品牌名称" min-width="150" />
        <el-table-column prop="domain" label="域名" width="200" />
        <el-table-column prop="merchant_count" label="商户数" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">
              {{ row.status === 'active' ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="updated_at" label="更新时间" width="180" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" @click="router.push(`/brands/${row.id}`)">
              查看
            </el-button>
            <el-button text type="primary" @click="router.push(`/brands/${row.id}`)">
              编辑
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Create Dialog -->
    <el-dialog v-model="showCreateDialog" title="新建品牌" width="500px">
      <el-form ref="createFormRef" :model="createForm" :rules="createRules" label-width="100px">
        <el-form-item label="品牌名称" prop="name">
          <el-input v-model="createForm.name" placeholder="请输入品牌名称" />
        </el-form-item>
        <el-form-item label="域名" prop="domain">
          <el-input v-model="createForm.domain" placeholder="请输入域名" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="createForm.description" type="textarea" :rows="3" placeholder="品牌描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" :loading="creating" @click="handleCreate">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { agentClient } from '@/api/client'

interface Brand {
  id: number
  name: string
  domain: string
  merchant_count: number
  status: string
  updated_at: string
}

const router = useRouter()
const loading = ref(false)
const creating = ref(false)
const brands = ref<Brand[]>([])
const showCreateDialog = ref(false)
const createFormRef = ref<FormInstance>()

const createForm = reactive({
  name: '',
  domain: '',
  description: '',
})

const createRules: FormRules = {
  name: [{ required: true, message: '请输入品牌名称', trigger: 'blur' }],
  domain: [{ required: true, message: '请输入域名', trigger: 'blur' }],
}

async function fetchBrands(): Promise<void> {
  loading.value = true
  try {
    const { data } = await agentClient.get('/brands')
    brands.value = data
  } catch {
    // Use empty list
  } finally {
    loading.value = false
  }
}

async function handleCreate(): Promise<void> {
  const valid = await createFormRef.value?.validate().catch(() => false)
  if (!valid) return

  creating.value = true
  try {
    const { data } = await agentClient.post('/brands', createForm)
    ElMessage.success('品牌创建成功')
    showCreateDialog.value = false
    router.push(`/brands/${data.id}`)
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '创建失败')
  } finally {
    creating.value = false
  }
}

onMounted(() => {
  fetchBrands()
})
</script>
