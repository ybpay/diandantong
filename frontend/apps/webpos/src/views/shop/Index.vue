<template>
  <BranchSelector v-if="authStore.shop" :branches="authStore.shop.branches" @select="handleSelect" />
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { BranchSelector } from '@webpos/ui'
import { useAuthStore } from '@webpos/stores'

const router = useRouter()
const authStore = useAuthStore()

function handleSelect(branch) {
  authStore.selectBranch(branch)
  const modeRoutes = {
    support_eat_in_hall: { name: 'eatInHall', params: { branchId: branch.id } },
    support_fast_food: { name: 'fastFood', params: { branchId: branch.id } },
    support_delivery: { name: 'delivery', params: { branchId: branch.id } },
  }
  for (const [key, route] of Object.entries(modeRoutes)) {
    if (branch[key]) {
      router.push(route)
      return
    }
  }
  router.push({ name: 'eatInHall', params: { branchId: branch.id } })
}
</script>
