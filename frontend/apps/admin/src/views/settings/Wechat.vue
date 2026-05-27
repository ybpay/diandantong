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
          <div class="w-full">
            <el-input v-if="secretsLoaded" v-model="wechatForm.officialAppSecret" type="password" show-password placeholder="公众号 AppSecret" />
            <el-input v-else :model-value="maskSecret(wechatForm.officialAppSecret)" disabled placeholder="点击显示" />
            <el-button v-if="!secretsLoaded" link type="primary" class="mt-1" @click="revealSecrets">显示密钥</el-button>
          </div>
        </el-form-item>

        <el-form-item label="消息推送 Token">
          <el-input v-model="wechatForm.officialToken" placeholder="Token" />
        </el-form-item>

        <el-form-item label="消息推送 EncodingAESKey">
          <div class="w-full">
            <el-input v-if="secretsLoaded" v-model="wechatForm.officialAesKey" type="password" show-password placeholder="EncodingAESKey" />
            <el-input v-else :model-value="maskSecret(wechatForm.officialAesKey)" disabled placeholder="点击显示" />
          </div>
        </el-form-item>

        <el-divider content-position="left">微信小程序</el-divider>

        <el-form-item label="小程序 AppID">
          <el-input v-model="wechatForm.miniAppId" placeholder="小程序 AppID" />
        </el-form-item>

        <el-form-item label="小程序 AppSecret">
          <div class="w-full">
            <el-input v-if="secretsLoaded" v-model="wechatForm.miniAppSecret" type="password" show-password placeholder="小程序 AppSecret" />
            <el-input v-else :model-value="maskSecret(wechatForm.miniAppSecret)" disabled placeholder="点击显示" />
          </div>
        </el-form-item>

        <el-form-item label="小程序名称">
          <el-input v-model="wechatForm.miniAppName" placeholder="小程序名称" />
        </el-form-item>

        <el-divider content-position="left">微信支付</el-divider>

        <el-form-item label="商户号 (MchID)">
          <el-input v-model="wechatForm.mchId" placeholder="微信支付商户号" />
        </el-form-item>

        <el-form-item label="API密钥">
          <div class="w-full">
            <el-input v-if="secretsLoaded" v-model="wechatForm.apiKey" type="password" show-password placeholder="API密钥" />
            <el-input v-else :model-value="maskSecret(wechatForm.apiKey)" disabled placeholder="点击显示" />
          </div>
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
import { ref, shallowRef } from 'vue'
import { ElMessage } from 'element-plus'

const saving = ref(false)

const wechatForm = ref({
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

const secretsLoaded = shallowRef(false)

function revealSecrets() {
  if (!secretsLoaded.value) {
    secretsLoaded.value = true
  }
}

function maskSecret(value: string): string {
  if (!value) return ''
  if (value.length <= 8) return '********'
  return value.slice(0, 4) + '****' + value.slice(-4)
}

const handleSave = () => {
  saving.value = true
  setTimeout(() => { saving.value = false; ElMessage.success('微信设置已保存') }, 500)
}
</script>
