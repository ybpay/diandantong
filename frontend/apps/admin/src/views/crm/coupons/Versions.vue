<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">优惠券版本管理</h2>
      <el-button type="primary" @click="showAddDialog">发布新版本</el-button>
    </div>

    <el-card shadow="never">
      <el-table :data="versions" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="version" label="版本号" width="100" />
        <el-table-column prop="couponName" label="优惠券" min-width="180" />
        <el-table-column prop="changes" label="变更内容" min-width="250" />
        <el-table-column prop="publishedBy" label="发布人" width="100" />
        <el-table-column prop="publishedAt" label="发布时间" width="160" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button text type="danger" size="small" @click="handleRollback(row)" v-if="row.status !== 'active'">回滚</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" title="发布新版本" width="480px">
      <el-form ref="formRef" :model="versionForm" :rules="rules" label-width="80px">
        <el-form-item label="优惠券" prop="couponId">
          <el-select v-model="versionForm.couponId" placeholder="选择优惠券" class="w-full">
            <el-option label="新用户专享券" :value="1" />
            <el-option label="午市折扣券" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="变更说明" prop="changes">
          <el-input v-model="versionForm.changes" type="textarea" :rows="3" placeholder="描述本次变更" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handlePublish">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const loading = ref(false)
const dialogVisible = ref(false)
const formRef = ref<FormInstance>()

const versions = ref([
  { id: 1, version: 'v3', couponName: '新用户专享券', changes: '满50减10 → 满60减15', publishedBy: '管理员', publishedAt: '2026-05-20 10:00', status: 'active', statusText: '当前版本' },
  { id: 2, version: 'v2', couponName: '新用户专享券', changes: '满30减5 → 满50减10', publishedBy: '管理员', publishedAt: '2026-03-15 14:30', status: 'archived', statusText: '已归档' },
  { id: 3, version: 'v1', couponName: '新用户专享券', changes: '初始版本：满30减5', publishedBy: '管理员', publishedAt: '2026-01-01 09:00', status: 'archived', statusText: '已归档' },
])

const versionForm = reactive({ couponId: undefined as number | undefined, changes: '' })
const rules: FormRules = {
  couponId: [{ required: true, message: '请选择优惠券', trigger: 'change' }],
  changes: [{ required: true, message: '请输入变更说明', trigger: 'blur' }],
}

const showAddDialog = () => { versionForm.couponId = undefined; versionForm.changes = ''; dialogVisible.value = true }
const handlePublish = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => { if (!valid) return; dialogVisible.value = false; ElMessage.success('新版本已发布') })
}
const handleView = (row: any) => { ElMessage.info(`查看版本 ${row.version}`) }
const handleRollback = (row: any) => { ElMessage.warning(`回滚到版本 ${row.version}`) }
</script>
