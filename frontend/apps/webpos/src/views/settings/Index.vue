<template>
  <PosLayout title="设置" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6">
      <h3 class="text-lg font-bold mb-4">系统设置</h3>
      <el-form label-width="120px" class="max-w-lg">
        <el-form-item label="终端ID">
          <el-input v-model="settings.terminalId" @change="saveTerminalId" />
        </el-form-item>
      </el-form>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { setTerminalId } from '@webpos/api'

const router = useRouter()
const authStore = useAuthStore()

const settings = reactive({
  terminalId: localStorage.getItem('terminal_id') || '',
})

function saveTerminalId() {
  localStorage.setItem('terminal_id', settings.terminalId)
  setTerminalId(settings.terminalId)
  ElMessage.success('已保存')
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}
</script>
