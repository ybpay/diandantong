<template>
  <div class="p-6 space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">菜品管理</h2>
      <el-button type="primary" @click="$router.push('/products/new')">新增菜品</el-button>
    </div>

    <!-- Search & Filters -->
    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="菜品名称">
          <el-input v-model="searchForm.keyword" placeholder="搜索菜品名称" clearable />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="searchForm.categoryId" placeholder="全部分类" clearable>
            <el-option v-for="cat in categories" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable>
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

    <!-- Product Table -->
    <el-card shadow="never">
      <el-table :data="products" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column label="图片" width="80">
          <template #default="{ row }">
            <el-image v-if="row.image" :src="row.image" class="w-10 h-10 rounded" fit="cover" />
            <div v-else class="w-10 h-10 bg-gray-100 rounded flex items-center justify-center text-gray-400 text-xs">无图</div>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="菜品名称" min-width="150" />
        <el-table-column prop="categoryName" label="分类" width="120" />
        <el-table-column prop="price" label="价格" width="100">
          <template #default="{ row }">&yen;{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="salesCount" label="销量" width="80" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.status"
              active-value="active"
              inactive-value="inactive"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="80" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="$router.push(`/products/${row.id}/edit`)">编辑</el-button>
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
  categoryId: '',
  status: '',
})

const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 4,
})

const categories = ref([
  { id: 1, name: '热菜' },
  { id: 2, name: '凉菜' },
  { id: 3, name: '主食' },
  { id: 4, name: '饮品' },
])

const products = ref([
  { id: 1, name: '宫保鸡丁', categoryName: '热菜', price: '38.00', image: '', salesCount: 256, status: 'active', sortOrder: 1 },
  { id: 2, name: '糖醋排骨', categoryName: '热菜', price: '48.00', image: '', salesCount: 189, status: 'active', sortOrder: 2 },
  { id: 3, name: '凉拌黄瓜', categoryName: '凉菜', price: '12.00', image: '', salesCount: 320, status: 'active', sortOrder: 3 },
  { id: 4, name: '蛋炒饭', categoryName: '主食', price: '15.00', image: '', salesCount: 450, status: 'inactive', sortOrder: 4 },
])

const handleSearch = () => {
  pagination.page = 1
  // TODO: call products API with search params
}

const handleReset = () => {
  searchForm.keyword = ''
  searchForm.categoryId = ''
  searchForm.status = ''
  handleSearch()
}

const handleStatusChange = (row: any) => {
  // TODO: call product status toggle API
  ElMessage.success(`菜品「${row.name}」已${row.status === 'active' ? '上架' : '下架'}`)
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm(`确定删除菜品「${row.name}」？`, '提示', { type: 'warning' })
  // TODO: call delete API
  ElMessage.success('删除成功')
}
</script>
