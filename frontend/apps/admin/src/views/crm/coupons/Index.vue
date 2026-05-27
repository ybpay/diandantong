<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">优惠券管理</h2>
      <el-button type="primary" @click="showAddDialog">新增优惠券</el-button>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="优惠券名称">
          <el-input v-model="searchForm.keyword" placeholder="搜索" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="进行中" value="active" />
            <el-option label="已暂停" value="paused" />
            <el-option label="已过期" value="expired" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="coupons" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="优惠券名称" min-width="180" />
        <el-table-column prop="type" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.type === '满减' ? 'danger' : 'success'" size="small">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="value" label="优惠额度" width="120" />
        <el-table-column prop="total" label="发行量" width="80" />
        <el-table-column prop="used" label="已领取" width="80" />
        <el-table-column prop="usedCount" label="已使用" width="80" />
        <el-table-column prop="validPeriod" label="有效期" min-width="200" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ row.statusText }}</el-tag>
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
          layout="total, sizes, prev, pager, next"
        />
      </div>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="editingCoupon ? '编辑优惠券' : '新增优惠券'" width="560px">
      <el-form ref="formRef" :model="couponForm" :rules="rules" label-width="100px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="couponForm.name" placeholder="优惠券名称" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="couponForm.type" class="w-full">
            <el-option label="满减券" value="满减" />
            <el-option label="折扣券" value="折扣" />
            <el-option label="赠品券" value="赠品" />
          </el-select>
        </el-form-item>
        <el-form-item label="优惠额度" prop="value">
          <el-input v-model="couponForm.value" placeholder="如：满100减20" />
        </el-form-item>
        <el-form-item label="发行量">
          <el-input-number v-model="couponForm.total" :min="0" class="w-full" />
        </el-form-item>
        <el-form-item label="有效期">
          <el-date-picker v-model="couponForm.validRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" class="w-full" />
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
const editingCoupon = ref<any>(null)
const formRef = ref<FormInstance>()

const searchForm = reactive({ keyword: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const coupons = ref([
  { id: 1, name: '新用户专享券', type: '满减', value: '满50减10', total: 1000, used: 456, usedCount: 230, validPeriod: '2026-01-01 ~ 2026-12-31', status: 'active', statusText: '进行中' },
  { id: 2, name: '午市折扣券', type: '折扣', value: '全场8.5折', total: 500, used: 320, usedCount: 180, validPeriod: '2026-05-01 ~ 2026-06-30', status: 'active', statusText: '进行中' },
  { id: 3, name: '周年庆满减', type: '满减', value: '满200减50', total: 2000, used: 2000, usedCount: 1500, validPeriod: '2026-03-01 ~ 2026-03-31', status: 'expired', statusText: '已过期' },
])

const couponForm = reactive({ name: '', type: '满减', value: '', total: 100, validRange: null as any })
const rules: FormRules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择类型', trigger: 'change' }],
}

const statusTag = (s: string) => ({ active: 'success', paused: 'warning', expired: 'info' }[s] ?? '')
const showAddDialog = () => { editingCoupon.value = null; dialogVisible.value = true }
const handleEdit = (row: any) => { editingCoupon.value = row; dialogVisible.value = true }
const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => { if (!valid) return; saving.value = true; setTimeout(() => { saving.value = false; dialogVisible.value = false; ElMessage.success('保存成功') }, 300) })
}
const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.keyword = ''; searchForm.status = ''; handleSearch() }
const handleDelete = async (row: any) => { await ElMessageBox.confirm(`确定删除优惠券「${row.name}」？`, '提示', { type: 'warning' }); ElMessage.success('删除成功') }
</script>
