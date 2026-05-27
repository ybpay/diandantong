<template>
  <el-container class="h-screen">
    <el-aside :width="isCollapsed ? '64px' : '220px'" class="transition-all duration-300 border-r border-gray-200 bg-white">
      <div class="h-full flex flex-col">
        <div class="h-16 flex items-center justify-center border-b border-gray-200">
          <h1 v-if="!isCollapsed" class="text-lg font-bold text-primary-600">点单通管理后台</h1>
          <span v-else class="text-xl font-bold text-primary-600">点</span>
        </div>
        <el-menu
          :default-active="currentRoute"
          :collapse="isCollapsed"
          :collapse-transition="false"
          router
          class="flex-1 border-r-0"
        >
          <el-menu-item index="/" @click="navigate('/')">
            <el-icon><DataBoard /></el-icon>
            <template #title>控制台</template>
          </el-menu-item>

          <el-sub-menu index="shop">
            <template #title>
              <el-icon><OfficeBuilding /></el-icon>
              <span>商户管理</span>
            </template>
            <el-menu-item index="/shop">店铺设置</el-menu-item>
            <el-menu-item index="/branches">门店管理</el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="product">
            <template #title>
              <el-icon><Goods /></el-icon>
              <span>商品管理</span>
            </template>
            <el-menu-item index="/categories">分类管理</el-menu-item>
            <el-menu-item index="/products">商品列表</el-menu-item>
            <el-menu-item index="/combos">套餐管理</el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="order">
            <template #title>
              <el-icon><Document /></el-icon>
              <span>订单管理</span>
            </template>
            <el-menu-item index="/orders/eat-in-hall">堂食订单</el-menu-item>
            <el-menu-item index="/orders/delivery">外卖订单</el-menu-item>
            <el-menu-item index="/orders/fastfood">快餐订单</el-menu-item>
            <el-menu-item index="/orders/groupon">团购订单</el-menu-item>
            <el-menu-item index="/orders/reservation">预订订单</el-menu-item>
            <el-menu-item index="/orders/recharge">充值订单</el-menu-item>
            <el-menu-item index="/orders/payment">代收款订单</el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="crm">
            <template #title>
              <el-icon><User /></el-icon>
              <span>会员管理</span>
            </template>
            <el-menu-item index="/vip">会员列表</el-menu-item>
            <el-menu-item index="/vip/levels">等级设置</el-menu-item>
            <el-menu-item index="/vip/settings">会员设置</el-menu-item>
            <el-menu-item index="/coupons">优惠券</el-menu-item>
            <el-menu-item index="/coupons/versions">券版本</el-menu-item>
            <el-menu-item index="/recharge">充值产品</el-menu-item>
            <el-menu-item index="/credits">积分设置</el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="marketing">
            <template #title>
              <el-icon><Present /></el-icon>
              <span>营销管理</span>
            </template>
            <el-menu-item index="/promotions">促销活动</el-menu-item>
            <el-menu-item index="/groupons">团购券</el-menu-item>
            <el-menu-item index="/vouchers">代金券</el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="statistics">
            <template #title>
              <el-icon><TrendCharts /></el-icon>
              <span>统计报表</span>
            </template>
            <el-menu-item index="/statistics/business">营业统计</el-menu-item>
            <el-menu-item index="/statistics/orders">订单统计</el-menu-item>
            <el-menu-item index="/statistics/products">商品统计</el-menu-item>
            <el-menu-item index="/statistics/finance">财务统计</el-menu-item>
            <el-menu-item index="/statistics/coupons">优惠券统计</el-menu-item>
            <el-menu-item index="/statistics/workers">员工统计</el-menu-item>
          </el-sub-menu>

          <el-menu-item index="/printers">
            <el-icon><Printer /></el-icon>
            <template #title>打印管理</template>
          </el-menu-item>

          <el-menu-item index="/queue">
            <el-icon><Tickets /></el-icon>
            <template #title>排队管理</template>
          </el-menu-item>

          <el-sub-menu index="settings">
            <template #title>
              <el-icon><Setting /></el-icon>
              <span>系统设置</span>
            </template>
            <el-menu-item index="/settings/roles">角色权限</el-menu-item>
            <el-menu-item index="/settings/accounts">账号管理</el-menu-item>
            <el-menu-item index="/settings/tables">桌台管理</el-menu-item>
            <el-menu-item index="/settings/wechat">微信设置</el-menu-item>
            <el-menu-item index="/settings/payment">支付设置</el-menu-item>
            <el-menu-item index="/settings/delivery">配送设置</el-menu-item>
            <el-menu-item index="/settings/print">打印设置</el-menu-item>
          </el-sub-menu>
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
import { useAdminAuthStore } from '@diandantong/admin-stores'

const router = useRouter()
const route = useRoute()
const authStore = useAdminAuthStore()

const isCollapsed = ref(false)

const currentRoute = computed(() => route.path)
const userName = computed(() => authStore.user?.name || '管理员')
const userInitial = computed(() => userName.value.charAt(0))
const currentPageTitle = computed(() => (route.meta.title as string) || '')

function navigate(path: string) {
  router.push(path)
}

async function handleLogout() {
  await authStore.logout()
  router.push({ name: 'login' })
}
</script>
