<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">分类管理</h2>
      <el-button type="primary" @click="showAddDialog">新增分类</el-button>
    </div>

    <el-card shadow="never">
      <el-table :data="categories" stripe row-key="id" default-expand-all v-loading="loading">
        <el-table-column prop="name" label="分类名称" min-width="200" />
        <el-table-column prop="productCount" label="菜品数量" width="120" />
        <el-table-column prop="sortOrder" label="排序" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">
              {{ row.status === 'active' ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text size="small" @click="handleMoveUp(row)">上移</el-button>
            <el-button text size="small" @click="handleMoveDown(row)">下移</el-button>
            <el-button text type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Add/Edit Dialog -->
    <el-dialog v-model="dialogVisible" :title="editingCategory ? '编辑分类' : '新增分类'" width="480px">
      <el-form ref="dialogFormRef" :model="categoryForm" :rules="formRules" label-width="80px">
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="categoryForm.name" placeholder="请输入分类名称" />
        </el-form-item>
        <el-form-item label="上级分类">
          <el-select v-model="categoryForm.parentId" placeholder="无（顶级分类）" clearable class="w-full">
            <el-option v-for="cat in topLevelCategories" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="排序权重">
          <el-input-number v-model="categoryForm.sortOrder" :min="0" :max="999" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="categoryForm.active" active-text="启用" inactive-text="禁用" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSaveCategory">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const loading = ref(false)
const saving = ref(false)
const dialogVisible = ref(false)
const editingCategory = ref<any>(null)
const dialogFormRef = ref<FormInstance>()

const categories = ref([
  { id: 1, name: '热菜', productCount: 25, sortOrder: 1, status: 'active', parentId: null },
  { id: 2, name: '凉菜', productCount: 12, sortOrder: 2, status: 'active', parentId: null },
  { id: 3, name: '主食', productCount: 8, sortOrder: 3, status: 'active', parentId: null },
  { id: 4, name: '饮品', productCount: 15, sortOrder: 4, status: 'active', parentId: null },
  { id: 5, name: '套餐', productCount: 6, sortOrder: 5, status: 'inactive', parentId: null },
])

const topLevelCategories = computed(() => categories.value.filter((c) => !c.parentId))

const categoryForm = reactive({
  name: '',
  parentId: undefined as number | undefined,
  sortOrder: 0,
  active: true,
})

const formRules: FormRules = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }],
}

const showAddDialog = () => {
  editingCategory.value = null
  categoryForm.name = ''
  categoryForm.parentId = undefined
  categoryForm.sortOrder = 0
  categoryForm.active = true
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  editingCategory.value = row
  categoryForm.name = row.name
  categoryForm.parentId = row.parentId ?? undefined
  categoryForm.sortOrder = row.sortOrder
  categoryForm.active = row.status === 'active'
  dialogVisible.value = true
}

const handleSaveCategory = async () => {
  if (!dialogFormRef.value) return
  await dialogFormRef.value.validate((valid) => {
    if (!valid) return
    saving.value = true
    // TODO: call category API
    setTimeout(() => {
      saving.value = false
      dialogVisible.value = false
      ElMessage.success(editingCategory.value ? '分类已更新' : '分类已创建')
    }, 300)
  })
}

const handleMoveUp = (row: any) => {
  // TODO: call reorder API
  ElMessage.success(`分类「${row.name}」已上移`)
}

const handleMoveDown = (row: any) => {
  // TODO: call reorder API
  ElMessage.success(`分类「${row.name}」已下移`)
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm(`确定删除分类「${row.name}」？该分类下有${row.productCount}个菜品。`, '提示', { type: 'warning' })
  // TODO: call delete API
  ElMessage.success('删除成功')
}
</script>
