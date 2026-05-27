<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useAgentAuthStore } from '@/stores/auth'

const authStore = useAgentAuthStore()

onMounted(() => {
  authStore.restore()
})
</script>
