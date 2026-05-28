<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">VIP等级配置</h2>
      <el-button type="primary" @click="showAddDialog">新增等级</el-button>
    </div>

    <el-card shadow="never">
      <el-table :data="levels" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="name" label="等级名称" width="120">
          <template #default="{ row }">
            <el-tag :type="row.tagType" size="small">{{ row.name }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="minSpent" label="累计消费门槛" width="150">
          <template #default="{ row }">&yen;{{ row.minSpent }}</template>
        </el-table-column>
        <el-table-column prop="discount" label="折扣" width="100">
          <template #default="{ row }">{{ row.discount }}折</template>
        </el-table-column>
        <el-table-column prop="pointsRate" label="积分倍率" width="100">
          <template #default="{ row }">{{ row.pointsRate }}x</template>
        </el-table-column>
        <el-table-column prop="freeDelivery" label="免配送费" width="100">
          <template #default="{ row }">
            <el-tag :type="row.freeDelivery ? 'success' : 'info'" size="small">{{ row.freeDelivery ? '是' : '否' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="birthdayGift" label="生日礼" width="100">
          <template #default="{ row }">
            <el-tag :type="row.birthdayGift ? 'success' : 'info'" size="small">{{ row.birthdayGift ? '是' : '否' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="memberCount" label="会员数" width="80" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text type="danger" size="small" @click="handleDelete(row)" :disabled="row.memberCount > 0">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="editingLevel ? '编辑等级' : '新增等级'" width="480px">
      <el-form ref="formRef" :model="levelForm" :rules="rules" label-width="120px">
        <el-form-item label="等级名称" prop="name">
          <el-input v-model="levelForm.name" placeholder="如：金卡" />
        </el-form-item>
        <el-form-item label="累计消费门槛" prop="minSpent">
          <el-input-number v-model="levelForm.minSpent" :min="0" class="w-full" />
        </el-form-item>
        <el-form-item label="折扣" prop="discount">
          <el-input-number v-model="levelForm.discount" :min="0" :max="10" :precision="1" :step="0.5" class="w-full" />
        </el-form-item>
        <el-form-item label="积分倍率">
          <el-input-number v-model="levelForm.pointsRate" :min="1" :max="10" :precision="1" :step="0.5" class="w-full" />
        </el-form-item>
        <el-form-item label="免配送费">
          <el-switch v-model="levelForm.freeDelivery" />
        </el-form-item>
        <el-form-item label="生日礼品">
          <el-switch v-model="levelForm.birthdayGift" />
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { vipLevelApi } from '@diandantong/admin-api'

const loading = ref(false)
const saving = ref(false)
const dialogVisible = ref(false)
const editingLevel = ref<any>(null)
const formRef = ref<FormInstance>()

const levels = ref<any[]>([])

const levelForm = reactive({ name: '', minSpent: 0, discount: 9.5, pointsRate: 1.0, freeDelivery: false, birthdayGift: false })
const rules: FormRules = {
  name: [{ required: true, message: '请输入等级名称', trigger: 'blur' }],
  minSpent: [{ required: true, message: '请输入门槛金额', trigger: 'blur' }],
  discount: [{ required: true, message: '请输入折扣', trigger: 'blur' }],
}

const fetchLevels = async () => {
  loading.value = true
  try {
    const { data } = await vipLevelApi.list()
    levels.value = (data as any)?.data || data || []
  } catch { ElMessage.error('获取VIP等级失败') }
  finally { loading.value = false }
}

const showAddDialog = () => { editingLevel.value = null; Object.assign(levelForm, { name: '', minSpent: 0, discount: 9.5, pointsRate: 1, freeDelivery: false, birthdayGift: false }); dialogVisible.value = true }
const handleEdit = (row: any) => { editingLevel.value = row; Object.assign(levelForm, { name: row.name, minSpent: row.upgrade_total_amount || row.minSpent, discount: row.discount, pointsRate: row.upgrade_get_credits || row.pointsRate, freeDelivery: row.freeDelivery, birthdayGift: row.birthdayGift }); dialogVisible.value = true }
const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    saving.value = true
    try {
      if (editingLevel.value) {
        await vipLevelApi.update(editingLevel.value.id, levelForm)
      } else {
        await vipLevelApi.create(levelForm)
      }
      dialogVisible.value = false
      ElMessage.success('保存成功')
      fetchLevels()
    } catch { ElMessage.error('保存失败') }
    finally { saving.value = false }
  })
}
const handleDelete = async (row: any) => {
  await ElMessageBox.confirm(`确定删除等级「${row.name}」？`, '提示', { type: 'warning' })
  try { await vipLevelApi.delete(row.id); ElMessage.success('删除成功'); fetchLevels() }
  catch { ElMessage.error('删除失败') }
}

onMounted(fetchLevels)
</script>
