<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">角色管理</h2>
      <el-button type="primary" @click="showAddDialog">新增角色</el-button>
    </div>

    <el-card shadow="never">
      <el-table :data="roles" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="角色名称" width="150" />
        <el-table-column prop="description" label="描述" min-width="200" />
        <el-table-column prop="memberCount" label="成员数" width="100" />
        <el-table-column prop="permissions" label="权限数" width="100" />
        <el-table-column prop="createdAt" label="创建时间" width="160" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button text size="small" @click="handlePermissions(row)">权限</el-button>
            <el-button text type="danger" size="small" @click="handleDelete(row)" :disabled="row.isSystem">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Permission Dialog -->
    <el-dialog v-model="permissionDialogVisible" title="权限配置" width="560px">
      <el-form label-width="80px">
        <el-form-item label="角色名称">
          <el-input v-model="roleForm.name" :disabled="!!editingRole" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="roleForm.description" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="权限配置">
          <el-tree
            ref="treeRef"
            :data="permissionTree"
            show-checkbox
            node-key="id"
            :default-checked-keys="roleForm.checkedKeys"
            class="max-h-80 overflow-y-auto"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="permissionDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSavePermissions">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const permissionDialogVisible = ref(false)
const editingRole = ref<any>(null)

const roles = ref([
  { id: 1, name: '超级管理员', description: '拥有所有权限', memberCount: 2, permissions: 45, createdAt: '2024-01-01', isSystem: true },
  { id: 2, name: '店长', description: '门店管理权限', memberCount: 5, permissions: 35, createdAt: '2024-01-01', isSystem: false },
  { id: 3, name: '收银员', description: '收银、订单管理', memberCount: 12, permissions: 15, createdAt: '2024-03-15', isSystem: false },
  { id: 4, name: '服务员', description: '点单、排队管理', memberCount: 20, permissions: 10, createdAt: '2024-03-15', isSystem: false },
])

const roleForm = reactive({ name: '', description: '', checkedKeys: [] as number[] })

const permissionTree = [
  { id: 100, label: '订单管理', children: [{ id: 101, label: '查看订单' }, { id: 102, label: '处理订单' }, { id: 103, label: '退款' }] },
  { id: 200, label: '菜品管理', children: [{ id: 201, label: '查看菜品' }, { id: 202, label: '新增/编辑菜品' }, { id: 203, label: '删除菜品' }] },
  { id: 300, label: '会员管理', children: [{ id: 301, label: '查看会员' }, { id: 302, label: '编辑会员' }, { id: 303, label: '充值' }] },
  { id: 400, label: '数据统计', children: [{ id: 401, label: '查看统计' }, { id: 402, label: '导出报表' }] },
  { id: 500, label: '系统设置', children: [{ id: 501, label: '店铺设置' }, { id: 502, label: '账号管理' }, { id: 503, label: '角色权限' }] },
]

const showAddDialog = () => { editingRole.value = null; roleForm.name = ''; roleForm.description = ''; roleForm.checkedKeys = []; permissionDialogVisible.value = true }
const handleEdit = (row: any) => { editingRole.value = row; roleForm.name = row.name; roleForm.description = row.description; roleForm.checkedKeys = []; permissionDialogVisible.value = true }
const handlePermissions = (row: any) => { handleEdit(row) }
const handleSavePermissions = () => { permissionDialogVisible.value = false; ElMessage.success('权限已保存') }
const handleDelete = async (row: any) => { await ElMessageBox.confirm(`确定删除角色「${row.name}」？`, '提示', { type: 'warning' }); ElMessage.success('删除成功') }
</script>
