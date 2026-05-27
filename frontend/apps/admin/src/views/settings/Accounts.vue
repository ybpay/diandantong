<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">账号管理</h2>
      <el-button type="primary" @click="showAddDialog">新增账号</el-button>
    </div>

    <el-card shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="关键词">
          <el-input v-model="searchForm.keyword" placeholder="姓名/用户名" clearable />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="searchForm.roleId" placeholder="全部角色" clearable>
            <el-option label="超级管理员" :value="1" />
            <el-option label="店长" :value="2" />
            <el-option label="收银员" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="accounts" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="realName" label="姓名" width="100" />
        <el-table-column prop="phone" label="手机号" width="120" />
        <el-table-column prop="roleName" label="角色" width="120">
          <template #default="{ row }">
            <el-tag size="small">{{ row.roleName }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="branchName" label="所属门店" width="120" />
        <el-table-column prop="lastLoginAt" label="最后登录" width="160" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'" size="small">{{ row.status === 'active' ? '正常' : '已停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text size="small" @click="handleResetPassword(row)">重置密码</el-button>
            <el-button text :type="row.status === 'active' ? 'danger' : 'success'" size="small" @click="handleToggleStatus(row)">{{ row.status === 'active' ? '禁用' : '启用' }}</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="editingAccount ? '编辑账号' : '新增账号'" width="480px">
      <el-form ref="formRef" :model="accountForm" :rules="rules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="accountForm.username" placeholder="用户名" :disabled="!!editingAccount" />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="accountForm.realName" placeholder="真实姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="accountForm.phone" placeholder="手机号" />
        </el-form-item>
        <el-form-item label="角色" prop="roleId">
          <el-select v-model="accountForm.roleId" class="w-full">
            <el-option label="店长" :value="2" />
            <el-option label="收银员" :value="3" />
            <el-option label="服务员" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="所属门店">
          <el-select v-model="accountForm.branchId" class="w-full">
            <el-option label="总店" :value="1" />
            <el-option label="城西分店" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!editingAccount">
          <el-input v-model="accountForm.password" type="password" placeholder="初始密码" show-password />
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
import type { AdminUser, AdminRole } from '@diandantong/admin-types'

interface AccountRow {
  id: number
  username: string
  realName: string
  phone: string
  roleName: string
  branchName: string
  lastLoginAt: string
  status: 'active' | 'inactive'
}

const loading = ref(false)
const saving = ref(false)
const dialogVisible = ref(false)
const editingAccount = ref<AccountRow | null>(null)
const formRef = ref<FormInstance>()

const searchForm = reactive({ keyword: '', roleId: '' })

const accounts = ref<AccountRow[]>([
  { id: 1, username: 'admin', realName: '管理员', phone: '138****0000', roleName: '超级管理员', branchName: '全部门店', lastLoginAt: '2026-05-27 09:00', status: 'active' },
  { id: 2, username: 'manager1', realName: '张店长', phone: '138****1111', roleName: '店长', branchName: '总店', lastLoginAt: '2026-05-27 08:30', status: 'active' },
  { id: 3, username: 'cashier1', realName: '李收银', phone: '139****2222', roleName: '收银员', branchName: '总店', lastLoginAt: '2026-05-26 18:00', status: 'active' },
  { id: 4, username: 'waiter1', realName: '王服务', phone: '137****3333', roleName: '服务员', branchName: '总店', lastLoginAt: '2026-05-27 10:00', status: 'active' },
])

const accountForm = reactive({ username: '', realName: '', phone: '', roleId: undefined as number | undefined, branchId: 1, password: '' })

const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  roleId: [{ required: true, message: '请选择角色', trigger: 'change' }],
  password: [{ required: true, message: '请输入初始密码', trigger: 'blur' }],
}

const showAddDialog = () => { editingAccount.value = null; Object.assign(accountForm, { username: '', realName: '', phone: '', roleId: undefined, branchId: 1, password: '' }); dialogVisible.value = true }
const handleEdit = (row: AccountRow) => { editingAccount.value = row; dialogVisible.value = true }
const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => { if (!valid) return; saving.value = true; setTimeout(() => { saving.value = false; dialogVisible.value = false; ElMessage.success('保存成功') }, 300) })
}
const handleSearch = () => { /* TODO */ }
const handleReset = () => { searchForm.keyword = ''; searchForm.roleId = ''; handleSearch() }
const handleResetPassword = async (row: AccountRow) => { await ElMessageBox.confirm(`确定重置「${row.realName}」的密码？`, '提示'); ElMessage.success('密码已重置为默认密码') }
const handleToggleStatus = (row: AccountRow) => { row.status = row.status === 'active' ? 'inactive' : 'active'; ElMessage.success(row.status === 'active' ? '已启用' : '已禁用') }
</script>
