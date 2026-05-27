<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">预约订单</h2>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="预约日期">
          <el-date-picker v-model="searchForm.date" placeholder="选择日期" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" clearable>
            <el-option label="待确认" value="pending" />
            <el-option label="已确认" value="confirmed" />
            <el-option label="已到店" value="arrived" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="reservations" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="orderNo" label="预约单号" width="170" />
        <el-table-column prop="customerName" label="客户" width="100" />
        <el-table-column prop="phone" label="电话" width="120" />
        <el-table-column prop="reserveDate" label="预约日期" width="120" />
        <el-table-column prop="reserveTime" label="预约时间" width="100" />
        <el-table-column prop="personCount" label="人数" width="80" />
        <el-table-column prop="tableNo" label="桌号" width="80">
          <template #default="{ row }">
            <span v-if="row.tableNo">{{ row.tableNo }}号</span>
            <el-tag v-else size="small" type="info">未排桌</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleConfirm(row)" v-if="row.status === 'pending'">确认</el-button>
            <el-button text type="danger" size="small" @click="handleCancel(row)" v-if="row.status !== 'cancelled'">取消</el-button>
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
import { ElMessage } from 'element-plus'

const loading = ref(false)

const searchForm = reactive({ date: '', status: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 3 })

const reservations = ref([
  { id: 1, orderNo: 'YY20260527001', customerName: '周九', phone: '136****1111', reserveDate: '2026-05-28', reserveTime: '18:00', personCount: 8, tableNo: '', status: 'pending', statusText: '待确认', remark: '生日聚餐' },
  { id: 2, orderNo: 'YY20260527002', customerName: '吴十', phone: '135****2222', reserveDate: '2026-05-28', reserveTime: '12:00', personCount: 4, tableNo: 'A5', status: 'confirmed', statusText: '已确认', remark: '' },
  { id: 3, orderNo: 'YY20260527003', customerName: '郑十一', phone: '137****3333', reserveDate: '2026-05-27', reserveTime: '18:30', personCount: 6, tableNo: 'B2', status: 'arrived', statusText: '已到店', remark: '靠窗' },
])

const statusTag = (s: string) => ({ pending: 'info', confirmed: '', arrived: 'success', cancelled: 'danger' }[s] ?? '')

const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.date = ''; searchForm.status = ''; handleSearch() }
const handleConfirm = (row: any) => { ElMessage.success(`已确认预约：${row.orderNo}`) }
const handleCancel = (row: any) => { ElMessage.warning(`已取消预约：${row.orderNo}`) }
</script>
