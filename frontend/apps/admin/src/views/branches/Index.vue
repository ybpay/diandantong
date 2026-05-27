<template>
  <div class="p-6 space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">门店管理</h2>
      <el-button type="primary" @click="$router.push('/branches/new')">新增门店</el-button>
    </div>

    <!-- Search Bar -->
    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="门店名称">
          <el-input v-model="searchForm.keyword" placeholder="搜索门店名称" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="营业中" value="active" />
            <el-option label="已关闭" value="inactive" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Branch Table -->
    <el-card shadow="never">
      <el-table :data="branches" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="门店名称" min-width="150" />
        <el-table-column prop="address" label="地址" min-width="200" />
        <el-table-column prop="phone" label="联系电话" width="140" />
        <el-table-column prop="businessHours" label="营业时间" width="160" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'" size="small">
              {{ row.status === 'active' ? '营业中' : '已关闭' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/branches/${row.id}`)">编辑</el-button>
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)

const searchForm = reactive({
  keyword: '',
  status: '',
})

const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 3,
})

const branches = ref([
  { id: 1, name: '总店（中心店）', address: '杭州市西湖区文三路100号', phone: '0571-88888888', businessHours: '09:00-22:00', status: 'active' },
  { id: 2, name: '城西分店', address: '杭州市西湖区学院路50号', phone: '0571-66666666', businessHours: '10:00-21:30', status: 'active' },
  { id: 3, name: '滨江分店', address: '杭州市滨江区江南大道200号', phone: '0571-77777777', businessHours: '10:00-22:00', status: 'inactive' },
])

const handleSearch = () => {
  // TODO: call branches API with search params
  pagination.page = 1
}

const handleReset = () => {
  searchForm.keyword = ''
  searchForm.status = ''
  handleSearch()
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm(`确定删除门店「${row.name}」？`, '提示', { type: 'warning' })
  // TODO: call delete API
  ElMessage.success('删除成功')
}
</script>
