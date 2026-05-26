<template>
  <BranchSelector v-if="authStore.shop" :branches="authStore.shop.branches" @select="handleSelect" />
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { BranchSelector } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'
import type { Branch } from '@webpos/types'

const router = useRouter()
const authStore = useAuthStore()

function handleSelect(branch: Branch) {
  authStore.selectBranch(branch)
  router.push({ name: 'extendedForm', params: { branchId: branch.id } })
}
</script>
