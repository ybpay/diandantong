<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">套餐管理</h2>
      <el-button type="primary" @click="showAddDialog">新增套餐</el-button>
    </div>

    <!-- Search -->
    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="套餐名称">
          <el-input v-model="searchForm.keyword" placeholder="搜索套餐" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="上架" value="active" />
            <el-option label="下架" value="inactive" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Combo Table -->
    <el-card shadow="never">
      <el-table :data="combos" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="套餐名称" min-width="180" />
        <el-table-column prop="items" label="包含菜品" min-width="250">
          <template #default="{ row }">
            <el-tag v-for="item in row.items" :key="item" size="small" class="mr-1 mb-1">{{ item }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="originalPrice" label="原价" width="100">
          <template #default="{ row }">&yen;{{ row.originalPrice }}</template>
        </el-table-column>
        <el-table-column prop="comboPrice" label="套餐价" width="100">
          <template #default="{ row }">
            <span class="text-red-500 font-semibold">&yen;{{ row.comboPrice }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="salesCount" label="销量" width="80" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch v-model="row.status" active-value="active" inactive-value="inactive" @change="handleStatusChange(row)" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="flex justify-end mt-4">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
        />
      </div>
    </el-card>

    <!-- Add/Edit Dialog -->
    <el-dialog v-model="dialogVisible" :title="editingCombo ? '编辑套餐' : '新增套餐'" width="600px">
      <el-form ref="formRef" :model="comboForm" :rules="rules" label-width="100px">
        <el-form-item label="套餐名称" prop="name">
          <el-input v-model="comboForm.name" placeholder="请输入套餐名称" />
        </el-form-item>
        <el-form-item label="原价" prop="originalPrice">
          <el-input-number v-model="comboForm.originalPrice" :min="0" :precision="2" class="w-full" />
        </el-form-item>
        <el-form-item label="套餐价" prop="comboPrice">
          <el-input-number v-model="comboForm.comboPrice" :min="0" :precision="2" class="w-full" />
        </el-form-item>
        <el-form-item label="包含菜品" prop="productIds">
          <el-select v-model="comboForm.productIds" multiple placeholder="选择菜品" class="w-full">
            <el-option v-for="p in availableProducts" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="套餐描述">
          <el-input v-model="comboForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const loading = ref(false)
const saving = ref(false)
const dialogVisible = ref(false)
const editingCombo = ref<any>(null)
const formRef = ref<FormInstance>()

const searchForm = reactive({ keyword: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const availableProducts = ref([
  { id: 1, name: '宫保鸡丁' },
  { id: 2, name: '糖醋排骨' },
  { id: 3, name: '蛋炒饭' },
  { id: 4, name: '酸辣汤' },
])

const combos = ref([
  { id: 1, name: '超值双人套餐', items: ['宫保鸡丁', '蛋炒饭', '酸辣汤'], originalPrice: '78.00', comboPrice: '58.00', salesCount: 120, status: 'active' },
  { id: 2, name: '家庭欢聚套餐', items: ['糖醋排骨', '宫保鸡丁', '蛋炒饭', '酸辣汤'], originalPrice: '118.00', comboPrice: '98.00', salesCount: 85, status: 'active' },
  { id: 3, name: '单人简餐', items: ['蛋炒饭', '酸辣汤'], originalPrice: '30.00', comboPrice: '25.00', salesCount: 230, status: 'inactive' },
])

const comboForm = reactive({
  name: '',
  originalPrice: 0,
  comboPrice: 0,
  productIds: [] as number[],
  description: '',
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入套餐名称', trigger: 'blur' }],
  comboPrice: [{ required: true, message: '请输入套餐价格', trigger: 'blur' }],
  productIds: [{ required: true, type: 'array', min: 1, message: '请至少选择一个菜品', trigger: 'change' }],
}

const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.keyword = ''; searchForm.status = ''; handleSearch() }

const showAddDialog = () => {
  editingCombo.value = null
  comboForm.name = ''
  comboForm.originalPrice = 0
  comboForm.comboPrice = 0
  comboForm.productIds = []
  comboForm.description = ''
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  editingCombo.value = row
  comboForm.name = row.name
  comboForm.productIds = []
  comboForm.description = ''
  dialogVisible.value = true
}

const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => {
    if (!valid) return
    saving.value = true
    setTimeout(() => { saving.value = false; dialogVisible.value = false; ElMessage.success('保存成功') }, 300)
  })
}

const handleStatusChange = (row: any) => {
  ElMessage.success(`套餐「${row.name}」已${row.status === 'active' ? '上架' : '下架'}`)
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm(`确定删除套餐「${row.name}」？`, '提示', { type: 'warning' })
  ElMessage.success('删除成功')
}
</script>
