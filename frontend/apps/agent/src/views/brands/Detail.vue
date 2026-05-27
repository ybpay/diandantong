<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-xl font-bold text-gray-800">品牌详情</h2>
      <el-button @click="router.back()">返回</el-button>
    </div>

    <template v-if="brand">
      <!-- Basic Info -->
      <el-card class="mb-4">
        <template #header>
          <div class="flex items-center justify-between">
            <span class="font-bold">基本信息</span>
            <el-button type="primary" @click="handleSave" :loading="saving">保存</el-button>
          </div>
        </template>
        <el-form :model="form" label-width="120px">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="品牌名称">
                <el-input v-model="form.name" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="域名">
                <el-input v-model="form.domain" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="描述">
            <el-input v-model="form.description" type="textarea" :rows="3" />
          </el-form-item>
          <el-form-item label="状态">
            <el-switch v-model="form.active" active-text="启用" inactive-text="停用" />
          </el-form-item>
        </el-form>
      </el-card>

      <!-- Brand Config -->
      <el-card class="mb-4">
        <template #header>
          <span class="font-bold">品牌配置</span>
        </template>
        <el-form :model="form.config" label-width="120px">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="主色调">
                <el-color-picker v-model="form.config.primaryColor" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="品牌Logo">
                <el-input v-model="form.config.logoUrl" placeholder="Logo URL" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="欢迎语">
                <el-input v-model="form.config.welcomeText" placeholder="首页欢迎语" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="客服电话">
                <el-input v-model="form.config.supportPhone" placeholder="客服电话" />
              </el-form-item>
            </el-col>
          </el-row>
        </el-form>
      </el-card>

      <!-- Merchants under this brand -->
      <el-card>
        <template #header>
          <span class="font-bold">旗下商户 ({{ brand.merchant_count }})</span>
        </template>
        <el-table :data="brandMerchants" stripe>
          <el-table-column prop="name" label="商户名称" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">
                {{ row.status === 'active' ? '活跃' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="expires_at" label="到期时间" width="180" />
        </el-table>
      </el-card>
    </template>

    <el-skeleton v-else :rows="8" animated />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { agentClient } from '@/api/client'

interface BrandMerchant {
  name: string
  status: string
  expires_at: string
}

interface Brand {
  id: number
  name: string
  domain: string
  description: string
  status: string
  merchant_count: number
  config: {
    primaryColor: string
    logoUrl: string
    welcomeText: string
    supportPhone: string
  }
}

const router = useRouter()
const route = useRoute()
const brandId = computed(() => route.params.id as string)
const brand = ref<Brand | null>(null)
const brandMerchants = ref<BrandMerchant[]>([])
const saving = ref(false)

const form = reactive({
  name: '',
  domain: '',
  description: '',
  active: true,
  config: {
    primaryColor: '#409eff',
    logoUrl: '',
    welcomeText: '',
    supportPhone: '',
  },
})

async function fetchBrand(): Promise<void> {
  try {
    const { data } = await agentClient.get(`/brands/${brandId.value}`)
    brand.value = data
    form.name = data.name
    form.domain = data.domain
    form.description = data.description
    form.active = data.status === 'active'
    if (data.config) {
      form.config = { ...form.config, ...data.config }
    }
    brandMerchants.value = data.merchants || []
  } catch {
    ElMessage.error('品牌不存在')
    router.back()
  }
}

async function handleSave(): Promise<void> {
  saving.value = true
  try {
    await agentClient.put(`/brands/${brandId.value}`, {
      name: form.name,
      domain: form.domain,
      description: form.description,
      status: form.active ? 'active' : 'inactive',
      config: form.config,
    })
    ElMessage.success('保存成功')
    fetchBrand()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchBrand()
})
</script>
