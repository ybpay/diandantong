<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">桌台管理</h2>
      <div class="flex gap-2">
        <el-button @click="$router.push('/settings/table-zones')">管理区域</el-button>
        <el-button type="primary" @click="showAddTableDialog">新增桌台</el-button>
      </div>
    </div>

    <!-- Zone Tabs -->
    <el-tabs v-model="activeZone" type="border-card">
      <el-tab-pane v-for="zone in zones" :key="zone.id" :label="zone.name" :name="String(zone.id)">
        <div class="mb-4 flex items-center justify-between">
          <span class="text-sm text-gray-500">{{ zone.name }} - 共{{ zone.tables.length }}桌</span>
          <el-button text type="danger" size="small" @click="handleDeleteZone(zone)" v-if="zone.id !== 0">删除区域</el-button>
        </div>

        <!-- Table Grid -->
        <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
          <div
            v-for="table in zone.tables"
            :key="table.id"
            class="border rounded-lg p-3 text-center cursor-pointer hover:border-blue-400 transition-colors"
            :class="table.status === 'occupied' ? 'bg-red-50 border-red-200' : 'bg-green-50 border-green-200'"
            @click="handleEditTable(table)"
          >
            <p class="font-semibold">{{ table.name }}</p>
            <p class="text-xs text-gray-500 mt-1">{{ table.capacity }}人桌</p>
            <el-tag :type="table.status === 'available' ? 'success' : table.status === 'occupied' ? 'danger' : 'warning'" size="small" class="mt-1">
              {{ table.statusText }}
            </el-tag>
            <p v-if="table.minSpend" class="text-xs text-gray-400 mt-1">最低消费 &yen;{{ table.minSpend }}</p>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- Add Zone Dialog -->
    <el-dialog v-model="zoneDialogVisible" title="新增区域" width="360px">
      <el-form :model="zoneForm" label-width="80px">
        <el-form-item label="区域名称"><el-input v-model="zoneForm.name" placeholder="如：大厅、包间区" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="zoneDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveZone">保存</el-button>
      </template>
    </el-dialog>

    <!-- Add/Edit Table Dialog -->
    <el-dialog v-model="tableDialogVisible" :title="editingTable ? '编辑桌台' : '新增桌台'" width="400px">
      <el-form :model="tableForm" label-width="80px">
        <el-form-item label="桌号"><el-input v-model="tableForm.name" placeholder="如：A1" /></el-form-item>
        <el-form-item label="容纳人数"><el-input-number v-model="tableForm.capacity" :min="1" :max="20" /></el-form-item>
        <el-form-item label="所属区域">
          <el-select v-model="tableForm.zoneId" class="w-full">
            <el-option v-for="z in zones" :key="z.id" :label="z.name" :value="z.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="最低消费"><el-input-number v-model="tableForm.minSpend" :min="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="tableDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveTable">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { tableApi } from '@diandantong/admin-api'

const activeZone = ref('1')
const zoneDialogVisible = ref(false)
const tableDialogVisible = ref(false)
const editingTable = ref<any>(null)
const loading = ref(false)

const zones = ref<any[]>([])

const zoneForm = reactive({ name: '' })
const tableForm = reactive({ name: '', capacity: 4, zoneId: 1, minSpend: 0 })

const fetchData = async () => {
  loading.value = true
  try {
    const { data } = await tableApi.listZones()
    const rawZones = (data as any)?.data || data || []
    zones.value = Array.isArray(rawZones) ? rawZones : []
    if (zones.value.length > 0) {
      activeZone.value = String(zones.value[0].id)
      for (const zone of zones.value) {
        try {
          const { data: tableData } = await tableApi.listTables({ zone_id: zone.id })
          zone.tables = (tableData as any)?.data || tableData || []
        } catch { zone.tables = [] }
      }
    }
  } catch { ElMessage.error('获取桌台数据失败') }
  finally { loading.value = false }
}

const showAddZoneDialog = () => { zoneForm.name = ''; zoneDialogVisible.value = true }
const showAddTableDialog = () => { editingTable.value = null; tableForm.name = ''; tableForm.capacity = 4; tableForm.zoneId = Number(activeZone.value); tableDialogVisible.value = true }
const handleEditTable = (table: any) => { editingTable.value = table; tableForm.name = table.name; tableForm.capacity = table.capacity; tableForm.minSpend = table.minSpend; tableDialogVisible.value = true }
const handleSaveZone = async () => {
  try {
    await tableApi.createZone({ name: zoneForm.name })
    zoneDialogVisible.value = false
    ElMessage.success('区域已添加')
    fetchData()
  } catch { ElMessage.error('添加区域失败') }
}
const handleSaveTable = async () => {
  try {
    if (editingTable.value) {
      await tableApi.updateTable(editingTable.value.id, { name: tableForm.name, capacity: tableForm.capacity, table_zone_id: tableForm.zoneId })
    } else {
      await tableApi.createTable({ name: tableForm.name, capacity: tableForm.capacity, table_zone_id: tableForm.zoneId })
    }
    tableDialogVisible.value = false
    ElMessage.success(editingTable.value ? '桌台已更新' : '桌台已添加')
    fetchData()
  } catch { ElMessage.error('保存桌台失败') }
}
const handleDeleteZone = async (zone: any) => {
  await ElMessageBox.confirm(`确定删除区域「${zone.name}」？`, '提示', { type: 'warning' })
  ElMessage.success('区域已删除')
}

onMounted(fetchData)
</script>
