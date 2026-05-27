<template>
  <div>
    <h2 class="text-xl font-bold text-gray-800 mb-6">OEM白标设置</h2>

    <!-- Logo & Branding -->
    <el-card class="mb-4">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="font-bold">品牌标识</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存</el-button>
        </div>
      </template>
      <el-form :model="form" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统名称">
              <el-input v-model="form.systemName" placeholder="如：点单通" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="公司名称">
              <el-input v-model="form.companyName" placeholder="公司名称" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="Logo URL">
              <el-input v-model="form.logoUrl" placeholder="Logo图片地址" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Favicon URL">
              <el-input v-model="form.faviconUrl" placeholder="Favicon图片地址" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <!-- Colors & Theme -->
    <el-card class="mb-4">
      <template #header>
        <span class="font-bold">主题配色</span>
      </template>
      <el-form :model="form.colors" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="主色调">
              <el-color-picker v-model="form.colors.primary" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="辅助色">
              <el-color-picker v-model="form.colors.secondary" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="强调色">
              <el-color-picker v-model="form.colors.accent" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <!-- Domain Settings -->
    <el-card class="mb-4">
      <template #header>
        <span class="font-bold">域名配置</span>
      </template>
      <el-form :model="form.domain" label-width="120px">
        <el-form-item label="主域名">
          <el-input v-model="form.domain.primary" placeholder="如：admin.example.com" />
        </el-form-item>
        <el-form-item label="H5域名">
          <el-input v-model="form.domain.h5" placeholder="如：h5.example.com" />
        </el-form-item>
        <el-form-item label="POS域名">
          <el-input v-model="form.domain.pos" placeholder="如：pos.example.com" />
        </el-form-item>
      </el-form>
    </el-card>

    <!-- WeChat Config -->
    <el-card>
      <template #header>
        <span class="font-bold">微信公众号配置</span>
      </template>
      <el-form :model="form.wechat" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="AppID">
              <el-input v-model="form.wechat.appId" placeholder="微信公众号AppID" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="AppSecret">
              <el-input v-model="form.wechat.appSecret" placeholder="微信公众号AppSecret" show-password />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { agentClient } from '@/api/client'

const saving = ref(false)

const form = reactive({
  systemName: '',
  companyName: '',
  logoUrl: '',
  faviconUrl: '',
  colors: {
    primary: '#409eff',
    secondary: '#67c23a',
    accent: '#e6a23c',
  },
  domain: {
    primary: '',
    h5: '',
    pos: '',
  },
  wechat: {
    appId: '',
    appSecret: '',
  },
})

async function fetchSettings(): Promise<void> {
  try {
    const { data } = await agentClient.get('/oem_settings')
    Object.assign(form, {
      systemName: data.system_name || '',
      companyName: data.company_name || '',
      logoUrl: data.logo_url || '',
      faviconUrl: data.favicon_url || '',
    })
    if (data.colors) Object.assign(form.colors, data.colors)
    if (data.domain) Object.assign(form.domain, data.domain)
    if (data.wechat) Object.assign(form.wechat, data.wechat)
  } catch {
    // Use defaults
  }
}

async function handleSave(): Promise<void> {
  saving.value = true
  try {
    await agentClient.put('/oem_settings', {
      system_name: form.systemName,
      company_name: form.companyName,
      logo_url: form.logoUrl,
      favicon_url: form.faviconUrl,
      colors: form.colors,
      domain: form.domain,
      wechat: form.wechat,
    })
    ElMessage.success('保存成功')
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchSettings()
})
</script>
