<script setup lang="ts">
import { BranchSelector } from '@webpos/ui'
import { useRouter } from 'vue-router'

const router = useRouter()

function onSelectBranch(branchId: string) {
  router.push({ name: 'kitchen', params: { branchId } })
}
</script>

<template>
  <div class="shop-page">
    <BranchSelector @select="onSelectBranch" />
  </div>
</template>

<style scoped>
.shop-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background-color: #f5f7fa;
}
</style>
