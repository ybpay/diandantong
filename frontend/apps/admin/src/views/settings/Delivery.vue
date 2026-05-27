<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">配送设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form :model="deliveryForm" label-width="160px" class="max-w-2xl">
        <el-divider content-position="left">基础设置</el-divider>

        <el-form-item label="启用外卖配送">
          <el-switch v-model="deliveryForm.enabled" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="配送费计算方式">
          <el-select v-model="deliveryForm.feeType" class="w-48">
            <el-option label="固定配送费" value="fixed" />
            <el-option label="按距离计费" value="distance" />
            <el-option label="满额免配送费" value="free_above" />
          </el-select>
        </el-form-item>

        <el-form-item label="固定配送费" v-if="deliveryForm.feeType === 'fixed'">
          <el-input-number v-model="deliveryForm.fixedFee" :min="0" :precision="2" />
          <span class="ml-2 text-gray-400">元</span>
        </el-form-item>

        <el-form-item label="免配送费门槛" v-if="deliveryForm.feeType === 'free_above'">
          <span class="mr-2">满</span>
          <el-input-number v-model="deliveryForm.freeAboveAmount" :min="0" :precision="2" style="width: 140px" />
          <span class="ml-2">元免配送费，否则收</span>
          <el-input-number v-model="deliveryForm.defaultFee" :min="0" :precision="2" style="width: 100px" />
          <span class="ml-2">元</span>
        </el-form-item>

        <el-divider content-position="left">配送范围</el-divider>

        <el-form-item label="最大配送距离">
          <el-input-number v-model="deliveryForm.maxDistance" :min="0.5" :max="20" :precision="1" :step="0.5" />
          <span class="ml-2 text-gray-400">公里</span>
        </el-form-item>

        <el-divider content-position="left">配送时段</el-divider>

        <el-form-item label="配送时间">
          <div class="space-y-2">
            <div v-for="(period, index) in deliveryForm.periods" :key="index" class="flex items-center gap-2">
              <el-time-select v-model="period.start" placeholder="开始" :start="'00:00'" :step="'00:30'" :end="'23:30'" />
              <span class="text-gray-400">至</span>
              <el-time-select v-model="period.end" placeholder="结束" :start="'00:00'" :step="'00:30'" :end="'23:30'" />
              <el-button text type="danger" @click="deliveryForm.periods.splice(index, 1)" :disabled="deliveryForm.periods.length <= 1">删除</el-button>
            </div>
            <el-button text type="primary" @click="deliveryForm.periods.push({ start: '', end: '' })">+ 添加时段</el-button>
          </div>
        </el-form-item>

        <el-divider content-position="left">配送提示</el-divider>

        <el-form-item label="预计配送时间">
          <el-input-number v-model="deliveryForm.estimatedMinutes" :min="10" :max="120" />
          <span class="ml-2 text-gray-400">分钟</span>
        </el-form-item>

        <el-form-item label="配送说明">
          <el-input v-model="deliveryForm.notice" type="textarea" :rows="2" placeholder="如：恶劣天气配送可能延迟" />
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const saving = ref(false)

const deliveryForm = reactive({
  enabled: true,
  feeType: 'fixed',
  fixedFee: 5,
  freeAboveAmount: 50,
  defaultFee: 5,
  maxDistance: 5,
  periods: [{ start: '10:00', end: '14:00' }, { start: '17:00', end: '21:30' }],
  estimatedMinutes: 30,
  notice: '',
})

const handleSave = () => {
  saving.value = true
  setTimeout(() => { saving.value = false; ElMessage.success('配送设置已保存') }, 500)
}
</script>
