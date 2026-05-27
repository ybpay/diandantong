<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">代金券管理</h2>
      <el-button type="primary" @click="showAddDialog">新增代金券</el-button>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="名称">
          <el-input v-model="searchForm.keyword" placeholder="搜索" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="可用" value="active" />
            <el-option label="已停用" value="inactive" />
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
      <el-table :data="vouchers" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="代金券名称" min-width="180" />
        <el-table-column prop="faceValue" label="面值" width="100">
          <template #default="{ row }">
            <span class="text-red-500 font-semibold">&yen;{{ row.faceValue }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="minSpend" label="使用门槛" width="120">
          <template #default="{ row }">满&yen;{{ row.minSpend }}可用</template>
        </el-table-column>
        <el-table-column prop="totalCount" label="发行量" width="80" />
        <el-table-column prop="issuedCount" label="已发放" width="80" />
        <el-table-column prop="usedCount" label="已使用" width="80" />
        <el-table-column prop="validPeriod" label="有效期" min-width="200" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text size="small" @click="handleIssue(row)">发放</el-button>
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

    <el-dialog v-model="dialogVisible" :title="editingVoucher ? '编辑代金券' : '新增代金券'" width="480px">
      <el-form :model="voucherForm" label-width="100px">
        <el-form-item label="名称"><el-input v-model="voucherForm.name" placeholder="代金券名称" /></el-form-item>
        <el-form-item label="面值"><el-input-number v-model="voucherForm.faceValue" :min="1" :precision="2" class="w-full" /></el-form-item>
        <el-form-item label="使用门槛"><el-input-number v-model="voucherForm.minSpend" :min="0" :precision="2" class="w-full" /></el-form-item>
        <el-form-item label="发行量"><el-input-number v-model="voucherForm.totalCount" :min="1" class="w-full" /></el-form-item>
        <el-form-item label="有效期">
          <el-date-picker v-model="voucherForm.validRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" class="w-full" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="dialogVisible = false">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const dialogVisible = ref(false)
const editingVoucher = ref<any>(null)

const searchForm = reactive({ keyword: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const voucherForm = reactive({ name: '', faceValue: 10, minSpend: 50, totalCount: 100, validRange: null as any })

const vouchers = ref([
  { id: 1, name: '新人50减10', faceValue: '10', minSpend: '50', totalCount: 1000, issuedCount: 456, usedCount: 230, validPeriod: '2026-01-01 ~ 2026-12-31', status: 'active', statusText: '可用' },
  { id: 2, name: '午市专享券', faceValue: '20', minSpend: '100', totalCount: 500, issuedCount: 320, usedCount: 180, validPeriod: '2026-05-01 ~ 2026-06-30', status: 'active', statusText: '可用' },
  { id: 3, name: '周年庆50元券', faceValue: '50', minSpend: '200', totalCount: 2000, issuedCount: 2000, usedCount: 1500, validPeriod: '2026-03-01 ~ 2026-03-31', status: 'expired', statusText: '已过期' },
])

const statusTag = (s: string) => ({ active: 'success', inactive: 'warning', expired: 'info' }[s] ?? '')

const showAddDialog = () => { editingVoucher.value = null; dialogVisible.value = true }
const handleEdit = (row: any) => { editingVoucher.value = row; dialogVisible.value = true }
const handleIssue = (row: any) => { ElMessage.info(`发放代金券「${row.name}」`) }
const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.keyword = ''; searchForm.status = ''; handleSearch() }
const handleDelete = async (row: any) => { await ElMessageBox.confirm(`确定删除「${row.name}」？`, '提示', { type: 'warning' }); ElMessage.success('删除成功') }
</script>
