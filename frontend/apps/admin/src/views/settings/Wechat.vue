<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">微信设置</span>
          <el-button type="primary" :loading="saving" @click="handleSave">保存设置</el-button>
        </div>
      </template>

      <el-form :model="wechatForm" label-width="160px" class="max-w-2xl">
        <el-divider content-position="left">微信公众号</el-divider>

        <el-form-item label="AppID">
          <el-input v-model="wechatForm.officialAppId" placeholder="公众号 AppID" />
        </el-form-item>

        <el-form-item label="AppSecret">
          <el-input v-model="wechatForm.officialAppSecret" type="password" show-password placeholder="公众号 AppSecret" />
        </el-form-item>

        <el-form-item label="消息推送 Token">
          <el-input v-model="wechatForm.officialToken" placeholder="Token" />
        </el-form-item>

        <el-form-item label="消息推送 EncodingAESKey">
          <el-input v-model="wechatForm.officialAesKey" type="password" show-password placeholder="EncodingAESKey" />
        </el-form-item>

        <el-divider content-position="left">微信小程序</el-divider>

        <el-form-item label="小程序 AppID">
          <el-input v-model="wechatForm.miniAppId" placeholder="小程序 AppID" />
        </el-form-item>

        <el-form-item label="小程序 AppSecret">
          <el-input v-model="wechatForm.miniAppSecret" type="password" show-password placeholder="小程序 AppSecret" />
        </el-form-item>

        <el-form-item label="小程序名称">
          <el-input v-model="wechatForm.miniAppName" placeholder="小程序名称" />
        </el-form-item>

        <el-divider content-position="left">微信支付</el-divider>

        <el-form-item label="商户号 (MchID)">
          <el-input v-model="wechatForm.mchId" placeholder="微信支付商户号" />
        </el-form-item>

        <el-form-item label="API密钥">
          <el-input v-model="wechatForm.apiKey" type="password" show-password placeholder="API密钥" />
        </el-form-item>

        <el-form-item label="证书上传">
          <el-upload action="#" :auto-upload="false" :show-file-list="false">
            <el-button>选择证书文件</el-button>
          </el-upload>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const saving = ref(false)

const wechatForm = reactive({
  officialAppId: '',
  officialAppSecret: '',
  officialToken: '',
  officialAesKey: '',
  miniAppId: '',
  miniAppSecret: '',
  miniAppName: '',
  mchId: '',
  apiKey: '',
})

const handleSave = () => {
  saving.value = true
  setTimeout(() => { saving.value = false; ElMessage.success('微信设置已保存') }, 500)
}
</script>
