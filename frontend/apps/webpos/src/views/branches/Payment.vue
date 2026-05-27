<template>
  <PosLayout
    title="收银台 - 快捷支付"
    :branch-name="authStore.currentBranch?.name"
    :branch-id="branchId"
    :user-name="authStore.userName"
    @command="handleCommand"
  >
    <div class="flex h-full items-center justify-center">
      <el-card class="w-96">
        <h3 class="text-lg font-bold mb-4 text-center">快捷支付</h3>
        <el-form>
          <el-form-item label="金额">
            <el-input-number v-model="amount" :min="0" :precision="2" size="large" class="w-full" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" size="large" class="w-full" @click="handlePay">确认支付</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const branchId = computed(() => Number(route.params.branchId))
const amount = ref(0)

function handlePay() {
  if (amount.value <= 0) {
    ElMessage.warning('请输入金额')
    return
  }
  ElMessage.info('快捷支付功能对接中')
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
