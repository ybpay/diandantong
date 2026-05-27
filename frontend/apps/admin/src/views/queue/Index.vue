<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">排队管理</h2>
      <el-button type="primary" @click="handleClearAll">清空排队</el-button>
    </div>

    <!-- Current Queue Status -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">当前排队</p>
          <p class="text-3xl font-bold text-blue-500 mt-2">{{ queueList.length }}桌</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">预计等待</p>
          <p class="text-3xl font-bold text-orange-500 mt-2">{{ estimatedWait }}分钟</p>
        </div>
      </el-card>
      <el-card shadow="hover">
        <div class="text-center">
          <p class="text-sm text-gray-500">今日已叫号</p>
          <p class="text-3xl font-bold text-green-500 mt-2">{{ calledCount }}桌</p>
        </div>
      </el-card>
    </div>

    <!-- Queue List -->
    <el-card shadow="never">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="font-semibold">排队列表</span>
          <el-button type="primary" size="small" @click="showAddDialog">手动取号</el-button>
        </div>
      </template>

      <el-table :data="queueList" stripe style="width: 100%">
        <el-table-column prop="queueNo" label="排队号" width="100">
          <template #default="{ row }">
            <span class="text-lg font-bold text-blue-500">{{ row.queueNo }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="personCount" label="用餐人数" width="100" />
        <el-table-column prop="tableType" label="桌型要求" width="120" />
        <el-table-column prop="customerName" label="联系人" width="100" />
        <el-table-column prop="phone" label="电话" width="120" />
        <el-table-column prop="waitTime" label="已等待" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'waiting' ? 'warning' : row.status === 'called' ? 'success' : 'info'" size="small">{{ row.statusText }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'waiting'" text type="success" size="small" @click="handleCall(row)">叫号</el-button>
            <el-button v-if="row.status === 'called'" text type="primary" size="small" @click="handleSeat(row)">入座</el-button>
            <el-button text type="danger" size="small" @click="handleSkip(row)">跳过</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" title="手动取号" width="400px">
      <el-form :model="queueForm" label-width="80px">
        <el-form-item label="用餐人数"><el-input-number v-model="queueForm.personCount" :min="1" :max="20" /></el-form-item>
        <el-form-item label="桌型要求">
          <el-select v-model="queueForm.tableType" class="w-full">
            <el-option label="小桌(1-2人)" value="small" />
            <el-option label="中桌(3-4人)" value="medium" />
            <el-option label="大桌(5-8人)" value="large" />
            <el-option label="包间" value="private" />
          </el-select>
        </el-form-item>
        <el-form-item label="联系人"><el-input v-model="queueForm.customerName" placeholder="可选" /></el-form-item>
        <el-form-item label="电话"><el-input v-model="queueForm.phone" placeholder="可选" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAddQueue">取号</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const dialogVisible = ref(false)
const calledCount = ref(12)

const queueList = ref([
  { id: 1, queueNo: 'A08', personCount: 4, tableType: '中桌', customerName: '张先生', phone: '138****1111', waitTime: '25分钟', status: 'waiting', statusText: '等待中' },
  { id: 2, queueNo: 'A09', personCount: 6, tableType: '大桌', customerName: '李女士', phone: '139****2222', waitTime: '20分钟', status: 'waiting', statusText: '等待中' },
  { id: 3, queueNo: 'A07', personCount: 2, tableType: '小桌', customerName: '', phone: '', waitTime: '30分钟', status: 'called', statusText: '已叫号' },
])

const estimatedWait = computed(() => queueList.value.filter(q => q.status === 'waiting').length * 10)

const queueForm = reactive({ personCount: 2, tableType: 'small', customerName: '', phone: '' })

const showAddDialog = () => { dialogVisible.value = true }
const handleAddQueue = () => { dialogVisible.value = false; ElMessage.success('取号成功') }
const handleCall = (row: any) => { row.status = 'called'; row.statusText = '已叫号'; ElMessage.success(`叫号：${row.queueNo}`) }
const handleSeat = (row: any) => { ElMessage.success(`${row.queueNo} 已入座`) }
const handleSkip = (row: any) => { ElMessage.warning(`跳过：${row.queueNo}`) }
const handleClearAll = async () => {
  await ElMessageBox.confirm('确定清空所有排队？', '警告', { type: 'warning' })
  ElMessage.success('排队已清空')
}
</script>
