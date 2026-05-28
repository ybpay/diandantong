<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">团购券管理</h2>
      <el-button type="primary" @click="showAddDialog">新增团购券</el-button>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="团购名称">
          <el-input v-model="searchForm.keyword" placeholder="搜索" clearable />
        </el-form-item>
        <el-form-item label="平台">
          <el-select v-model="searchForm.platform" placeholder="全部" clearable>
            <el-option label="美团" value="meituan" />
            <el-option label="大众点评" value="dianping" />
            <el-option label="抖音" value="douyin" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="groupons" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="title" label="团购名称" min-width="200" />
        <el-table-column prop="platform" label="平台" width="100">
          <template #default="{ row }">
            <el-tag size="small" :type="row.platform === '美团' ? 'warning' : row.platform === '大众点评' ? 'success' : ''">{{ row.platform }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="originalPrice" label="原价" width="100">
          <template #default="{ row }">&yen;{{ row.originalPrice }}</template>
        </el-table-column>
        <el-table-column prop="grouponPrice" label="团购价" width="100">
          <template #default="{ row }"><span class="text-red-500">&yen;{{ row.grouponPrice }}</span></template>
        </el-table-column>
        <el-table-column prop="soldCount" label="已售" width="80" />
        <el-table-column prop="usedCount" label="已核销" width="80" />
        <el-table-column prop="pendingCount" label="待使用" width="80" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
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

    <el-dialog v-model="dialogVisible" title="编辑团购券" width="480px">
      <el-form :model="grouponForm" label-width="80px">
        <el-form-item label="名称"><el-input v-model="grouponForm.title" /></el-form-item>
        <el-form-item label="原价"><el-input-number v-model="grouponForm.originalPrice" :min="0" :precision="2" class="w-full" /></el-form-item>
        <el-form-item label="团购价"><el-input-number v-model="grouponForm.grouponPrice" :min="0" :precision="2" class="w-full" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="dialogVisible = false">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { grouponApi } from '@diandantong/admin-api'

const loading = ref(false)
const dialogVisible = ref(false)

const searchForm = reactive({ keyword: '', platform: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 0 })

const grouponForm = reactive({ title: '', originalPrice: 0, grouponPrice: 0 })

const groupons = ref<any[]>([])

const fetchGroupons = async () => {
  loading.value = true
  try {
    const { data } = await grouponApi.list({ page: pagination.page, per_page: pagination.pageSize })
    const result = (data as any)?.data || data
    groupons.value = Array.isArray(result) ? result : result?.items || []
    pagination.total = (data as any)?.total || (data as any)?.meta?.total || groupons.value.length
  } catch { ElMessage.error('获取团购券列表失败') }
  finally { loading.value = false }
}

const handleSearch = () => { pagination.page = 1; fetchGroupons() }
const handleReset = () => { searchForm.keyword = ''; searchForm.platform = ''; handleSearch() }
const handleEdit = (row: any) => { grouponForm.title = row.title; dialogVisible.value = true }
const handleDelete = async (row: any) => {
  await ElMessageBox.confirm(`确定删除「${row.title}」？`, '提示', { type: 'warning' })
  try { await grouponApi.delete(row.id); ElMessage.success('删除成功'); fetchGroupons() }
  catch { ElMessage.error('删除失败') }
}

onMounted(fetchGroupons)
</script>
