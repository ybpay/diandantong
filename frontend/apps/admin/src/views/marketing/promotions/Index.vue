<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">促销活动管理</h2>
      <el-button type="primary" @click="$router.push('/marketing/promotions/new')">创建促销</el-button>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="活动名称">
          <el-input v-model="searchForm.keyword" placeholder="搜索" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="进行中" value="active" />
            <el-option label="待开始" value="scheduled" />
            <el-option label="已结束" value="ended" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="promotions" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="活动名称" min-width="200" />
        <el-table-column prop="type" label="类型" width="120">
          <template #default="{ row }">
            <el-tag size="small">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="period" label="活动时间" min-width="200" />
        <el-table-column prop="participantCount" label="参与人数" width="100" />
        <el-table-column prop="orderCount" label="产生订单" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/marketing/promotions/${row.id}/edit`)">编辑</el-button>
            <el-button text type="danger" size="small" @click="handleDelete(row)">删除</el-button>
            <el-button text size="small" @click="handleViewStats(row)">数据</el-button>
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const searchForm = reactive({ keyword: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const promotions = ref([
  { id: 1, name: '五一劳动节满减活动', type: '满减', period: '2026-05-01 ~ 2026-05-05', participantCount: 356, orderCount: 289, status: 'ended', statusText: '已结束' },
  { id: 2, name: '夏日清凉折扣', type: '折扣', period: '2026-06-01 ~ 2026-08-31', participantCount: 0, orderCount: 0, status: 'scheduled', statusText: '待开始' },
  { id: 3, name: '会员日特惠', type: '满减', period: '2026-05-25 ~ 2026-05-31', participantCount: 128, orderCount: 96, status: 'active', statusText: '进行中' },
])

const statusTag = (s: string) => ({ active: 'success', scheduled: 'info', ended: '' }[s] ?? '')
const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.keyword = ''; searchForm.status = ''; handleSearch() }
const handleDelete = async (row: any) => { await ElMessageBox.confirm(`确定删除「${row.name}」？`, '提示', { type: 'warning' }); ElMessage.success('删除成功') }
const handleViewStats = (row: any) => { ElMessage.info(`查看「${row.name}」数据`) }
</script>
