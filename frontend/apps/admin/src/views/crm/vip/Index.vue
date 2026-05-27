<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">VIP会员管理</h2>
      <el-button type="primary" @click="showAddDialog">新增会员</el-button>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="关键词">
          <el-input v-model="searchForm.keyword" placeholder="姓名/手机号" clearable />
        </el-form-item>
        <el-form-item label="会员等级">
          <el-select v-model="searchForm.level" placeholder="全部等级" clearable>
            <el-option v-for="lv in levels" :key="lv.value" :label="lv.label" :value="lv.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="members" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="phone" label="手机号" width="120" />
        <el-table-column prop="level" label="等级" width="100">
          <template #default="{ row }">
            <el-tag :type="levelTag(row.level)" size="small">{{ row.levelName }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="balance" label="余额" width="100">
          <template #default="{ row }">&yen;{{ row.balance }}</template>
        </el-table-column>
        <el-table-column prop="points" label="积分" width="80" />
        <el-table-column prop="totalSpent" label="累计消费" width="100">
          <template #default="{ row }">&yen;{{ row.totalSpent }}</template>
        </el-table-column>
        <el-table-column prop="orderCount" label="订单数" width="80" />
        <el-table-column prop="registeredAt" label="注册时间" width="160" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text size="small" @click="handleRecharge(row)">充值</el-button>
            <el-button text type="danger" size="small" @click="handleDisable(row)">{{ row.disabled ? '启用' : '禁用' }}</el-button>
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

    <!-- Add/Edit Dialog -->
    <el-dialog v-model="dialogVisible" :title="editingMember ? '编辑会员' : '新增会员'" width="480px">
      <el-form ref="formRef" :model="memberForm" :rules="rules" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="memberForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="memberForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="生日">
          <el-date-picker v-model="memberForm.birthday" type="date" placeholder="选择生日" class="w-full" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="memberForm.remark" type="textarea" :rows="2" />
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
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const loading = ref(false)
const saving = ref(false)
const dialogVisible = ref(false)
const editingMember = ref<any>(null)
const formRef = ref<FormInstance>()

const levels = [
  { value: 'silver', label: '银卡' },
  { value: 'gold', label: '金卡' },
  { value: 'platinum', label: '铂金' },
  { value: 'diamond', label: '钻石' },
]

const searchForm = reactive({ keyword: '', level: '' })
const pagination = reactive({ page: 1, pageSize: 10, total: 4 })

const members = ref([
  { id: 1, name: '王会员', phone: '138****5555', level: 'diamond', levelName: '钻石', balance: '2,350.00', points: 8900, totalSpent: '15,680.00', orderCount: 86, disabled: false, registeredAt: '2024-03-15' },
  { id: 2, name: '李会员', phone: '139****6666', level: 'gold', levelName: '金卡', balance: '1,150.00', points: 4500, totalSpent: '8,200.00', orderCount: 42, disabled: false, registeredAt: '2024-06-20' },
  { id: 3, name: '张会员', phone: '137****7777', level: 'silver', levelName: '银卡', balance: '210.00', points: 1200, totalSpent: '3,500.00', orderCount: 18, disabled: false, registeredAt: '2025-01-10' },
  { id: 4, name: '赵会员', phone: '136****8888', level: 'platinum', levelName: '铂金', balance: '800.00', points: 6200, totalSpent: '12,300.00', orderCount: 65, disabled: false, registeredAt: '2024-08-05' },
])

const memberForm = reactive({ name: '', phone: '', birthday: '', remark: '' })

const rules: FormRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
}

const levelTag = (l: string) => ({ silver: 'info', gold: 'warning', platinum: '', diamond: 'success' }[l] ?? '')

const showAddDialog = () => { editingMember.value = null; memberForm.name = ''; memberForm.phone = ''; memberForm.birthday = ''; memberForm.remark = ''; dialogVisible.value = true }
const handleEdit = (row: any) => { editingMember.value = row; memberForm.name = row.name; memberForm.phone = row.phone; memberForm.birthday = ''; memberForm.remark = ''; dialogVisible.value = true }
const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => { if (!valid) return; saving.value = true; setTimeout(() => { saving.value = false; dialogVisible.value = false; ElMessage.success('保存成功') }, 300) })
}
const handleSearch = () => { pagination.page = 1 }
const handleReset = () => { searchForm.keyword = ''; searchForm.level = ''; handleSearch() }
const handleRecharge = (row: any) => { ElMessage.info(`为${row.name}充值`) }
const handleDisable = (row: any) => { ElMessage.success(row.disabled ? '已启用' : '已禁用') }
</script>
