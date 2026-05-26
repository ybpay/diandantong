<template>
  <PosLayout title="打印机管理" :branch-name="authStore.currentBranch?.name" :branch-id="branchId" :user-name="authStore.userName" @command="handleCommand">
    <div class="p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-bold">打印机列表</h3>
        <div class="flex gap-2">
          <el-button @click="testPrintAll">全部测试打印</el-button>
          <el-button @click="fetchPrinters">刷新状态</el-button>
        </div>
      </div>
      <el-table :data="printers" stripe>
        <el-table-column prop="name" label="名称" />
        <el-table-column prop="printer_type" label="类型" />
        <el-table-column label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 'online' ? 'success' : 'danger'">{{ row.status === 'online' ? '在线' : '离线' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button size="small" @click="testPrint(row.id)">测试打印</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </PosLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { PosLayout } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import { printerApi } from '@webpos/api'
import type { Printer } from '@webpos/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const branchId = computed(() => Number(route.params.branchId))
const printers = ref<Printer[]>([])

async function fetchPrinters() {
  try {
    const { data } = await printerApi.list(branchId.value)
    printers.value = data
  } catch {
    ElMessage.error('加载打印机列表失败')
  }
}

async function testPrint(printerId: number) {
  try {
    await printerApi.testPrint(branchId.value, printerId)
    ElMessage.success('已发送测试打印')
  } catch {
    ElMessage.error('测试打印失败')
  }
}

async function testPrintAll() {
  try {
    await printerApi.testPrintAll(branchId.value)
    ElMessage.success('已发送全部测试打印')
  } catch {
    ElMessage.error('测试打印失败')
  }
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录?').then(async () => {
      await authStore.logout()
      router.push({ name: 'signIn' })
    }).catch(() => {})
  }
}

onMounted(fetchPrinters)
</script>
