<template>
  <BranchSelector v-if="authStore.shop" :branches="authStore.shop.branches" @select="handleSelect" />
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { BranchSelector } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'

const router = useRouter()
const authStore = useAuthStore()

function handleSelect(branch: { id: number }) {
  authStore.selectBranch(branch)
  router.push({ name: 'estimate', params: { branchId: branch.id } })
}
</script>
