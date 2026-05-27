<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">打印机管理</h2>
      <el-button type="primary" @click="showAddDialog">添加打印机</el-button>
    </div>

    <el-card shadow="never">
      <el-table :data="printers" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="打印机名称" min-width="180" />
        <el-table-column prop="type" label="类型" width="120">
          <template #default="{ row }">
            <el-tag size="small">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sn" label="设备SN号" width="160" />
        <el-table-column prop="branchName" label="所属门店" width="120" />
        <el-table-column prop="autoPrint" label="自动打印" width="100">
          <template #default="{ row }">
            <el-tag :type="row.autoPrint ? 'success' : 'info'" size="small">{{ row.autoPrint ? '已开启' : '已关闭' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'online' ? 'success' : 'danger'" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text size="small" @click="handleTestPrint(row)">测试打印</el-button>
            <el-button text type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="editingPrinter ? '编辑打印机' : '添加打印机'" width="480px">
      <el-form :model="printerForm" label-width="100px">
        <el-form-item label="名称"><el-input v-model="printerForm.name" placeholder="打印机名称" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="printerForm.type" class="w-full">
            <el-option label="前台小票打印机" value="receipt" />
            <el-option label="后厨出单机" value="kitchen" />
            <el-option label="标签打印机" value="label" />
          </el-select>
        </el-form-item>
        <el-form-item label="设备SN号"><el-input v-model="printerForm.sn" placeholder="设备SN号" /></el-form-item>
        <el-form-item label="所属门店">
          <el-select v-model="printerForm.branchId" class="w-full">
            <el-option label="总店" :value="1" />
            <el-option label="城西分店" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="自动打印"><el-switch v-model="printerForm.autoPrint" /></el-form-item>
        <el-form-item label="打印份数"><el-input-number v-model="printerForm.copies" :min="1" :max="5" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const dialogVisible = ref(false)
const editingPrinter = ref<any>(null)

const printers = ref([
  { id: 1, name: '前台小票机', type: '小票', sn: 'PRN-001-ABCD', branchName: '总店', autoPrint: true, status: 'online', statusText: '在线' },
  { id: 2, name: '后厨出单机', type: '后厨', sn: 'PRN-002-EFGH', branchName: '总店', autoPrint: true, status: 'online', statusText: '在线' },
  { id: 3, name: '城西前台机', type: '小票', sn: 'PRN-003-IJKL', branchName: '城西分店', autoPrint: true, status: 'offline', statusText: '离线' },
])

const printerForm = reactive({ name: '', type: 'receipt', sn: '', branchId: 1, autoPrint: true, copies: 1 })

const showAddDialog = () => { editingPrinter.value = null; dialogVisible.value = true }
const handleEdit = (row: any) => { editingPrinter.value = row; dialogVisible.value = true }
const handleSave = () => { dialogVisible.value = false; ElMessage.success('保存成功') }
const handleTestPrint = (row: any) => { ElMessage.info(`测试打印：${row.name}`) }
const handleDelete = async (row: any) => { await ElMessageBox.confirm(`确定删除「${row.name}」？`, '提示', { type: 'warning' }); ElMessage.success('删除成功') }
</script>
