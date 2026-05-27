<template>
  <div class="table-map">
    <div class="flex items-center gap-2 mb-4">
      <el-select v-model="selectedZoneId" placeholder="选择区域" @change="handleZoneChange">
        <el-option v-for="zone in zones" :key="zone.id" :label="zone.name" :value="zone.id" />
      </el-select>
      <el-button @click="emit('refresh')">刷新</el-button>
    </div>

    <div class="grid grid-cols-4 gap-3">
      <div
        v-for="table in displayTables"
        :key="table.id"
        class="table-cell p-4 rounded-lg cursor-pointer transition-all border-2"
        :class="tableClass(table)"
        @click="emit('select', table)"
      >
        <div class="font-bold text-center">{{ table.name }}</div>
        <div class="text-xs text-center mt-1">{{ table.seats }}人</div>
        <div class="text-xs text-center mt-1">
          <span v-if="table.status === 'idle'" class="text-green-600">空闲</span>
          <span v-else-if="table.status === 'occupied'" class="text-red-500">就餐中</span>
          <span v-else-if="table.status === 'reserved'" class="text-yellow-500">已预约</span>
          <span v-else-if="table.status === 'ordering'" class="text-blue-500">点餐中</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import type { Table, TableZone } from '@webpos/types'

const props = defineProps<{
  zones: TableZone[]
  tables: Table[]
}>()

const emit = defineEmits<{
  (e: 'select', table: Table): void
  (e: 'refresh'): void
}>()

const selectedZoneId = ref<number | null>(null)

const displayTables = computed(() => {
  if (!selectedZoneId.value) return props.tables
  return props.tables.filter((t) => t.zone_id === selectedZoneId.value)
})

function tableClass(table: Table) {
  const base = {
    'idle': 'bg-green-50 border-green-300 hover:bg-green-100',
    'occupied': 'bg-red-50 border-red-300 hover:bg-red-100',
    'reserved': 'bg-yellow-50 border-yellow-300 hover:bg-yellow-100',
    'ordering': 'bg-blue-50 border-blue-300 hover:bg-blue-100',
  }
  return base[table.status] || 'bg-gray-50 border-gray-300'
}

function handleZoneChange() {
  // Filter is handled by computed
}
</script>
