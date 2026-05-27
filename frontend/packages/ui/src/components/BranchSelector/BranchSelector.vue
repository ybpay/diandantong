<template>
  <div class="branch-selector min-h-screen flex items-center justify-center bg-gray-100">
    <el-card class="w-[480px] shadow-lg">
      <template #header>
        <h2 class="text-xl font-bold text-center">选择门店</h2>
      </template>
      <div class="space-y-2">
        <div
          v-for="branch in branches"
          :key="branch.id"
          class="branch-item p-4 rounded-lg border border-gray-200 cursor-pointer hover:bg-primary-50 hover:border-primary-300 transition-colors"
          @click="emit('select', branch)"
        >
          <div class="font-medium">{{ branch.name }}</div>
          <div class="text-sm text-gray-500 mt-1 flex gap-2 flex-wrap">
            <el-tag v-if="branch.support_eat_in_hall" size="small" type="primary">堂食</el-tag>
            <el-tag v-if="branch.support_fast_food" size="small" type="success">快餐</el-tag>
            <el-tag v-if="branch.support_delivery" size="small" type="warning">外卖</el-tag>
            <el-tag v-if="branch.support_reservation" size="small" type="info">预约</el-tag>
            <el-tag v-if="branch.support_queue" size="small">排队</el-tag>
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import type { Branch } from '@webpos/types'

defineProps<{
  branches: Branch[]
}>()

const emit = defineEmits<{
  (e: 'select', branch: Branch): void
}>()
</script>
