<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useAdminAuthStore } from '@diandantong/admin-stores'

const authStore = useAdminAuthStore()

onMounted(() => {
  authStore.restore()
})
</script>
