<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">区域管理</h2>
      <el-button type="primary" @click="showAddDialog">新增区域</el-button>
    </div>

    <el-table :data="zones" v-loading="loading" stripe border>
      <el-table-column prop="name" label="区域名称" min-width="120" />
      <el-table-column label="桌台数量" width="100" align="center">
        <template #default="{ row }">{{ row.tables?.length ?? 0 }}</template>
      </el-table-column>
      <el-table-column prop="min_reservation_price" label="最低预订金额" width="140" align="right">
        <template #default="{ row }">&yen;{{ row.min_reservation_price ?? 0 }}</template>
      </el-table-column>
      <el-table-column prop="reservation_price_percent" label="订金比例(%)" width="120" align="right" />
      <el-table-column prop="tables_count_for_reservation" label="可预订桌数" width="110" align="center" />
      <el-table-column label="禁止自助买单" width="120" align="center">
        <template #default="{ row }">
          <el-tag :type="row.ban_selfpay ? 'danger' : 'success'" size="small">
            {{ row.ban_selfpay ? '是' : '否' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="160" fixed="right" align="center">
        <template #default="{ row }">
          <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
          <el-button text type="danger" size="small" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- Add/Edit Dialog -->
    <el-dialog v-model="dialogVisible" :title="editing ? '编辑区域' : '新增区域'" width="480px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="区域名称" prop="name">
          <el-input v-model="form.name" placeholder="如：大厅、包间区" />
        </el-form-item>
        <el-form-item label="最低预订金额" prop="min_reservation_price">
          <el-input-number v-model="form.min_reservation_price" :min="0" :precision="2" />
          <span class="ml-2 text-gray-400">元</span>
        </el-form-item>
        <el-form-item label="订金比例" prop="reservation_price_percent">
          <el-input-number v-model="form.reservation_price_percent" :min="0" :max="100" :precision="1" />
          <span class="ml-2 text-gray-400">%</span>
        </el-form-item>
        <el-form-item label="可预订桌数" prop="tables_count_for_reservation">
          <el-input-number v-model="form.tables_count_for_reservation" :min="0" />
        </el-form-item>
        <el-form-item label="禁止自助买单">
          <el-switch v-model="form.ban_selfpay" active-text="是" inactive-text="否" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { tableApi } from '@diandantong/admin-api'
import type { AdminTableZone } from '@diandantong/admin-types'

const loading = ref(false)
const submitting = ref(false)
const dialogVisible = ref(false)
const editing = ref<AdminTableZone | null>(null)
const formRef = ref<FormInstance>()

const zones = ref<AdminTableZone[]>([])

const defaultForm = () => ({
  name: '',
  min_reservation_price: 0,
  reservation_price_percent: 0,
  tables_count_for_reservation: 0,
  ban_selfpay: false,
})
const form = reactive(defaultForm())

const rules: FormRules = {
  name: [{ required: true, message: '请输入区域名称', trigger: 'blur' }],
  min_reservation_price: [{ required: true, message: '请输入最低预订金额', trigger: 'change' }],
}

const fetchData = async () => {
  loading.value = true
  try {
    const { data } = await tableApi.listZones()
    zones.value = ((data as any)?.data || data || []) as AdminTableZone[]
  } catch {
    ElMessage.error('获取区域数据失败')
  } finally {
    loading.value = false
  }
}

const showAddDialog = () => {
  editing.value = null
  Object.assign(form, defaultForm())
  dialogVisible.value = true
}

const handleEdit = (zone: AdminTableZone) => {
  editing.value = zone
  Object.assign(form, {
    name: zone.name,
    min_reservation_price: zone.min_reservation_price ?? 0,
    reservation_price_percent: zone.reservation_price_percent ?? 0,
    tables_count_for_reservation: zone.tables_count_for_reservation ?? 0,
    ban_selfpay: zone.ban_selfpay ?? false,
  })
  dialogVisible.value = true
}

const handleSubmit = async () => {
  await formRef.value?.validate()
  submitting.value = true
  try {
    if (editing.value) {
      await tableApi.updateZone?.(editing.value.id, form)
    } else {
      await tableApi.createZone(form)
    }
    dialogVisible.value = false
    ElMessage.success(editing.value ? '区域已更新' : '区域已创建')
    fetchData()
  } catch {
    ElMessage.error('保存失败')
  } finally {
    submitting.value = false
  }
}

const handleDelete = async (zone: AdminTableZone) => {
  await ElMessageBox.confirm(`确定删除区域「${zone.name}」？该操作不可撤销。`, '提示', { type: 'warning' })
  try {
    await tableApi.deleteZone?.(zone.id)
    ElMessage.success('区域已删除')
    fetchData()
  } catch {
    ElMessage.error('删除失败')
  }
}

const resetForm = () => {
  formRef.value?.resetFields()
}

onMounted(fetchData)
</script>
