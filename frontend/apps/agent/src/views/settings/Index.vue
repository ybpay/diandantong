<template>
  <div>
    <h2 class="text-xl font-bold text-gray-800 mb-6">系统设置</h2>

    <!-- Profile Settings -->
    <el-card class="mb-4">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="font-bold">个人信息</span>
          <el-button type="primary" :loading="savingProfile" @click="handleSaveProfile">保存</el-button>
        </div>
      </template>
      <el-form :model="profileForm" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="姓名">
              <el-input v-model="profileForm.name" placeholder="姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱">
              <el-input v-model="profileForm.email" placeholder="邮箱" disabled />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="联系电话">
              <el-input v-model="profileForm.phone" placeholder="联系电话" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <!-- Password Settings -->
    <el-card class="mb-4">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="font-bold">修改密码</span>
          <el-button type="primary" :loading="savingPassword" @click="handleChangePassword">
            修改密码
          </el-button>
        </div>
      </template>
      <el-form :model="passwordForm" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="当前密码">
              <el-input v-model="passwordForm.currentPassword" type="password" show-password />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="新密码">
              <el-input v-model="passwordForm.newPassword" type="password" show-password />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="确认密码">
              <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <!-- Notification Settings -->
    <el-card class="mb-4">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="font-bold">通知设置</span>
          <el-button type="primary" :loading="savingNotification" @click="handleSaveNotification">保存</el-button>
        </div>
      </template>
      <el-form :model="notificationForm" label-width="160px">
        <el-form-item label="商户到期提醒">
          <el-switch v-model="notificationForm.expirationReminder" />
        </el-form-item>
        <el-form-item label="新商户通知">
          <el-switch v-model="notificationForm.newMerchantNotify" />
        </el-form-item>
        <el-form-item label="续费通知">
          <el-switch v-model="notificationForm.renewalNotify" />
        </el-form-item>
        <el-form-item label="提醒天数">
          <el-input-number v-model="notificationForm.remindDays" :min="1" :max="90" />
          <span class="ml-2 text-gray-500">天</span>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- System Info -->
    <el-card>
      <template #header>
        <span class="font-bold">系统信息</span>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="系统版本">1.0.0</el-descriptions-item>
        <el-descriptions-item label="构建时间">{{ buildTime }}</el-descriptions-item>
        <el-descriptions-item label="代理等级">{{ agentLevel }}</el-descriptions-item>
        <el-descriptions-item label="管辖商户">{{ managedMerchants }}</el-descriptions-item>
      </el-descriptions>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { agentClient } from '@/api/client'
import { useAgentAuthStore } from '@/stores/auth'

const authStore = useAgentAuthStore()
const savingProfile = ref(false)
const savingPassword = ref(false)
const savingNotification = ref(false)
const buildTime = ref(new Date().toISOString().split('T')[0])
const agentLevel = ref('-')
const managedMerchants = ref(0)

const profileForm = reactive({
  name: '',
  email: '',
  phone: '',
})

const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

const notificationForm = reactive({
  expirationReminder: true,
  newMerchantNotify: true,
  renewalNotify: true,
  remindDays: 30,
})

async function fetchSettings(): Promise<void> {
  try {
    const { data } = await agentClient.get('/settings')
    profileForm.name = data.name || ''
    profileForm.email = data.email || ''
    profileForm.phone = data.phone || ''
    agentLevel.value = data.agent_level || '-'
    managedMerchants.value = data.managed_merchants || 0
    if (data.notifications) {
      Object.assign(notificationForm, data.notifications)
    }
  } catch {
    // Use defaults
  }
}

async function handleSaveProfile(): Promise<void> {
  savingProfile.value = true
  try {
    await agentClient.put('/settings/profile', {
      name: profileForm.name,
      phone: profileForm.phone,
    })
    ElMessage.success('保存成功')
    authStore.fetchUser()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
  } finally {
    savingProfile.value = false
  }
}

async function handleChangePassword(): Promise<void> {
  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    ElMessage.error('两次密码不一致')
    return
  }
  if (passwordForm.newPassword.length < 6) {
    ElMessage.error('密码至少6位')
    return
  }
  savingPassword.value = true
  try {
    await agentClient.put('/settings/password', {
      current_password: passwordForm.currentPassword,
      new_password: passwordForm.newPassword,
    })
    ElMessage.success('密码修改成功')
    passwordForm.currentPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '修改失败')
  } finally {
    savingPassword.value = false
  }
}

async function handleSaveNotification(): Promise<void> {
  savingNotification.value = true
  try {
    await agentClient.put('/settings/notifications', notificationForm)
    ElMessage.success('保存成功')
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
  } finally {
    savingNotification.value = false
  }
}

onMounted(() => {
  fetchSettings()
})
</script>
