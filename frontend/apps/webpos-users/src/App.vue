<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useAuthStore } from '@webpos/stores'

const authStore = useAuthStore()

onMounted(() => {
  authStore.restore()
})
</script>
