<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">打印设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form :model="printForm" label-width="160px" class="max-w-2xl">
        <el-divider content-position="left">自动打印规则</el-divider>

        <el-form-item label="新订单自动打印">
          <el-switch v-model="printForm.autoPrintNewOrder" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <el-form-item label="前台小票" v-if="printForm.autoPrintNewOrder">
          <el-checkbox-group v-model="printForm.frontPrintEvents">
            <el-checkbox label="新订单" value="new_order" />
            <el-checkbox label="订单完成" value="order_completed" />
            <el-checkbox label="退款" value="refund" />
          </el-checkbox-group>
        </el-form-item>

        <el-form-item label="后厨出单" v-if="printForm.autoPrintNewOrder">
          <el-checkbox-group v-model="printForm.kitchenPrintEvents">
            <el-checkbox label="新订单" value="new_order" />
            <el-checkbox label="加菜" value="add_item" />
            <el-checkbox label="退菜" value="remove_item" />
          </el-checkbox-group>
        </el-form-item>

        <el-divider content-position="left">打印份数</el-divider>

        <el-form-item label="前台打印份数">
          <el-input-number v-model="printForm.frontCopies" :min="1" :max="5" />
        </el-form-item>

        <el-form-item label="后厨打印份数">
          <el-input-number v-model="printForm.kitchenCopies" :min="1" :max="5" />
        </el-form-item>

        <el-divider content-position="left">小票模板</el-divider>

        <el-form-item label="小票头部">
          <el-input v-model="printForm.headerText" placeholder="如：感谢惠顾" />
        </el-form-item>

        <el-form-item label="小票底部">
          <el-input v-model="printForm.footerText" placeholder="如：欢迎再次光临" />
        </el-form-item>

        <el-form-item label="显示门店地址">
          <el-switch v-model="printForm.showAddress" />
        </el-form-item>

        <el-form-item label="显示联系电话">
          <el-switch v-model="printForm.showPhone" />
        </el-form-item>

        <el-form-item label="显示二维码">
          <el-switch v-model="printForm.showQrCode" />
          <span class="ml-2 text-gray-400">打印小程序二维码</span>
        </el-form-item>

        <el-divider content-position="left">标签打印</el-divider>

        <el-form-item label="启用标签打印">
          <el-switch v-model="printForm.labelPrintEnabled" />
        </el-form-item>

        <el-form-item label="标签内容" v-if="printForm.labelPrintEnabled">
          <el-checkbox-group v-model="printForm.labelFields">
            <el-checkbox label="菜品名称" value="name" />
            <el-checkbox label="价格" value="price" />
            <el-checkbox label="桌号" value="table" />
            <el-checkbox label="下单时间" value="time" />
            <el-checkbox label="备注" value="remark" />
          </el-checkbox-group>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const saving = ref(false)

const printForm = reactive({
  autoPrintNewOrder: true,
  frontPrintEvents: ['new_order', 'order_completed', 'refund'],
  kitchenPrintEvents: ['new_order', 'add_item', 'remove_item'],
  frontCopies: 1,
  kitchenCopies: 1,
  headerText: '',
  footerText: '',
  showAddress: true,
  showPhone: true,
  showQrCode: false,
  labelPrintEnabled: false,
  labelFields: ['name', 'price', 'table', 'time'],
})

const handleSave = () => {
  saving.value = true
  setTimeout(() => { saving.value = false; ElMessage.success('打印设置已保存') }, 500)
}
</script>
