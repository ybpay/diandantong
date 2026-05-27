<template>
  <el-container class="h-screen">
    <el-aside :width="isCollapsed ? '64px' : '220px'" class="transition-all duration-300 border-r border-gray-200 bg-white">
      <div class="h-full flex flex-col">
        <div class="h-16 flex items-center justify-center border-b border-gray-200">
          <h1 v-if="!isCollapsed" class="text-lg font-bold text-blue-600">点单通代理系统</h1>
          <span v-else class="text-xl font-bold text-blue-600">代</span>
        </div>
        <el-menu
          :default-active="currentRoute"
          :collapse="isCollapsed"
          :collapse-transition="false"
          router
          class="flex-1 border-r-0"
        >
          <el-menu-item index="/dashboard" @click="navigate('/')">
            <el-icon><DataBoard /></el-icon>
            <template #title>控制台</template>
          </el-menu-item>

          <el-menu-item index="/merchants" @click="navigate('/merchants')">
            <el-icon><OfficeBuilding /></el-icon>
            <template #title>商户管理</template>
          </el-menu-item>

          <el-menu-item index="/expirations" @click="navigate('/expirations')">
            <el-icon><Timer /></el-icon>
            <template #title>到期管理</template>
          </el-menu-item>

          <el-menu-item index="/brands" @click="navigate('/brands')">
            <el-icon><PriceTag /></el-icon>
            <template #title>品牌配置</template>
          </el-menu-item>

          <el-menu-item index="/oem" @click="navigate('/oem')">
            <el-icon><Brush /></el-icon>
            <template #title>OEM设置</template>
          </el-menu-item>

          <el-menu-item index="/agents" @click="navigate('/agents')">
            <el-icon><User /></el-icon>
            <template #title>子代理</template>
          </el-menu-item>

          <el-menu-item index="/statistics" @click="navigate('/statistics')">
            <el-icon><TrendCharts /></el-icon>
            <template #title>数据统计</template>
          </el-menu-item>

          <el-menu-item index="/settings" @click="navigate('/settings')">
            <el-icon><Setting /></el-icon>
            <template #title>系统设置</template>
          </el-menu-item>
        </el-menu>
      </div>
    </el-aside>

    <el-container>
      <el-header class="flex items-center justify-between border-b border-gray-200 bg-white px-4">
        <div class="flex items-center gap-3">
          <el-button :icon="isCollapsed ? Expand : Fold" text @click="isCollapsed = !isCollapsed" />
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="currentPageTitle">{{ currentPageTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="flex items-center gap-4">
          <el-dropdown>
            <span class="cursor-pointer flex items-center gap-2">
              <el-avatar :size="32">{{ userInitial }}</el-avatar>
              <span class="text-sm">{{ userName }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <el-main class="bg-gray-50 p-6">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Expand, Fold } from '@element-plus/icons-vue'
import { useAgentAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAgentAuthStore()

const isCollapsed = ref(false)

const currentRoute = computed(() => route.path)
const userName = computed(() => authStore.user?.name || '代理商')
const userInitial = computed(() => userName.value.charAt(0))
const currentPageTitle = computed(() => (route.meta.title as string) || '')

function navigate(path: string) {
  router.push(path)
}

async function handleLogout() {
  authStore.logout()
  router.push({ name: 'login' })
}
</script>
