<template>
  <div class="p-6 space-y-6">
    <h2 class="text-lg font-semibold">系统设置</h2>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <el-card shadow="hover" class="cursor-pointer hover:border-blue-300 transition-colors" @click="$router.push('/settings/shop')">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-blue-500"><Shop /></el-icon>
          </div>
          <div>
            <p class="font-semibold">店铺设置</p>
            <p class="text-sm text-gray-400">店铺信息、营业时间、联系方式</p>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="cursor-pointer hover:border-green-300 transition-colors" @click="$router.push('/settings/roles')">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-green-500"><User /></el-icon>
          </div>
          <div>
            <p class="font-semibold">角色权限</p>
            <p class="text-sm text-gray-400">管理角色、分配操作权限</p>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="cursor-pointer hover:border-purple-300 transition-colors" @click="$router.push('/settings/accounts')">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-purple-500"><UserFilled /></el-icon>
          </div>
          <div>
            <p class="font-semibold">账号管理</p>
            <p class="text-sm text-gray-400">员工账号、登录管理</p>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="cursor-pointer hover:border-orange-300 transition-colors" @click="$router.push('/settings/tables')">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-orange-500"><Grid /></el-icon>
          </div>
          <div>
            <p class="font-semibold">桌台管理</p>
            <p class="text-sm text-gray-400">桌号、区域、容量设置</p>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="cursor-pointer hover:border-cyan-300 transition-colors" @click="$router.push('/settings/wechat')">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-cyan-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-cyan-500"><ChatDotRound /></el-icon>
          </div>
          <div>
            <p class="font-semibold">微信设置</p>
            <p class="text-sm text-gray-400">公众号、小程序配置</p>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="cursor-pointer hover:border-red-300 transition-colors" @click="$router.push('/settings/payment')">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-red-500"><CreditCard /></el-icon>
          </div>
          <div>
            <p class="font-semibold">支付设置</p>
            <p class="text-sm text-gray-400">支付方式、收款配置</p>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="cursor-pointer hover:border-yellow-300 transition-colors" @click="$router.push('/settings/delivery')">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-yellow-600"><Van /></el-icon>
          </div>
          <div>
            <p class="font-semibold">配送设置</p>
            <p class="text-sm text-gray-400">配送费、配送范围、时段</p>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="cursor-pointer hover:border-gray-300 transition-colors" @click="$router.push('/settings/print')">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-gray-100 rounded-lg flex items-center justify-center">
            <el-icon :size="24" class="text-gray-500"><Printer /></el-icon>
          </div>
          <div>
            <p class="font-semibold">打印设置</p>
            <p class="text-sm text-gray-400">打印模板、自动打印规则</p>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Shop, User, UserFilled, Grid, ChatDotRound, CreditCard, Van, Printer } from '@element-plus/icons-vue'
</script>
