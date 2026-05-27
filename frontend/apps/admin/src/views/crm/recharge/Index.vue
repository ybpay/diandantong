<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">充值产品管理</h2>
      <el-button type="primary" @click="showAddDialog">新增充值产品</el-button>
    </div>

    <el-card shadow="never">
      <el-table :data="products" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="产品名称" min-width="200" />
        <el-table-column prop="payAmount" label="支付金额" width="120">
          <template #default="{ row }">&yen;{{ row.payAmount }}</template>
        </el-table-column>
        <el-table-column prop="giftAmount" label="赠送金额" width="120">
          <template #default="{ row }"><span class="text-red-500">+&yen;{{ row.giftAmount }}</span></template>
        </el-table-column>
        <el-table-column prop="giftPoints" label="赠送积分" width="100" />
        <el-table-column prop="salesCount" label="销量" width="80" />
        <el-table-column prop="sortOrder" label="排序" width="80" />
        <el-table-column prop="active" label="状态" width="100">
          <template #default="{ row }">
            <el-switch v-model="row.active" @change="handleStatusChange(row)" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="editingProduct ? '编辑充值产品' : '新增充值产品'" width="480px">
      <el-form ref="formRef" :model="productForm" :rules="rules" label-width="100px">
        <el-form-item label="产品名称" prop="name">
          <el-input v-model="productForm.name" placeholder="如：充500送50" />
        </el-form-item>
        <el-form-item label="支付金额" prop="payAmount">
          <el-input-number v-model="productForm.payAmount" :min="1" :precision="2" class="w-full" />
        </el-form-item>
        <el-form-item label="赠送金额">
          <el-input-number v-model="productForm.giftAmount" :min="0" :precision="2" class="w-full" />
        </el-form-item>
        <el-form-item label="赠送积分">
          <el-input-number v-model="productForm.giftPoints" :min="0" class="w-full" />
        </el-form-item>
        <el-form-item label="排序权重">
          <el-input-number v-model="productForm.sortOrder" :min="0" :max="999" />
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
const editingProduct = ref<any>(null)
const formRef = ref<FormInstance>()

const products = ref([
  { id: 1, name: '充200送10', payAmount: '200', giftAmount: '10', giftPoints: 200, salesCount: 350, sortOrder: 1, active: true },
  { id: 2, name: '充500送50', payAmount: '500', giftAmount: '50', giftPoints: 500, salesCount: 280, sortOrder: 2, active: true },
  { id: 3, name: '充1000送150', payAmount: '1000', giftAmount: '150', giftPoints: 1000, salesCount: 120, sortOrder: 3, active: true },
  { id: 4, name: '充2000送400', payAmount: '2000', giftAmount: '400', giftPoints: 2000, salesCount: 45, sortOrder: 4, active: false },
])

const productForm = reactive({ name: '', payAmount: 100, giftAmount: 0, giftPoints: 0, sortOrder: 0 })
const rules: FormRules = {
  name: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
  payAmount: [{ required: true, message: '请输入支付金额', trigger: 'blur' }],
}

const showAddDialog = () => { editingProduct.value = null; Object.assign(productForm, { name: '', payAmount: 100, giftAmount: 0, giftPoints: 0, sortOrder: 0 }); dialogVisible.value = true }
const handleEdit = (row: any) => { editingProduct.value = row; dialogVisible.value = true }
const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => { if (!valid) return; saving.value = true; setTimeout(() => { saving.value = false; dialogVisible.value = false; ElMessage.success('保存成功') }, 300) })
}
const handleStatusChange = (row: any) => { ElMessage.success(`充值产品已${row.active ? '上架' : '下架'}`) }
const handleDelete = async (row: any) => { await ElMessageBox.confirm(`确定删除「${row.name}」？`, '提示', { type: 'warning' }); ElMessage.success('删除成功') }
</script>
