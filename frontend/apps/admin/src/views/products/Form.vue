<template>
  <div class="p-6">
    <el-card shadow="hover">
      <template #header>
        <div class="flex items-center justify-between">
          <span class="text-lg font-semibold">{{ isEdit ? '编辑菜品' : '新增菜品' }}</span>
          <el-button @click="$router.back()">返回</el-button>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="productForm"
        :rules="rules"
        label-width="120px"
        class="max-w-2xl"
      >
        <el-form-item label="菜品名称" prop="name">
          <el-input v-model="productForm.name" placeholder="请输入菜品名称" />
        </el-form-item>

        <el-form-item label="所属分类" prop="categoryId">
          <el-select v-model="productForm.categoryId" placeholder="请选择分类" class="w-full">
            <el-option v-for="cat in categories" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="价格" prop="price">
          <el-input-number v-model="productForm.price" :min="0" :precision="2" :step="1" class="w-full" />
        </el-form-item>

        <el-form-item label="原价" prop="originalPrice">
          <el-input-number v-model="productForm.originalPrice" :min="0" :precision="2" :step="1" class="w-full" />
        </el-form-item>

        <el-form-item label="菜品图片">
          <el-upload
            action="#"
            :auto-upload="false"
            :show-file-list="false"
            accept="image/*"
            list-type="picture-card"
          >
            <el-icon :size="28"><Plus /></el-icon>
          </el-upload>
        </el-form-item>

        <el-form-item label="菜品描述">
          <el-input v-model="productForm.description" type="textarea" :rows="3" placeholder="请输入菜品描述" />
        </el-form-item>

        <el-form-item label="排序权重">
          <el-input-number v-model="productForm.sortOrder" :min="0" :max="999" />
        </el-form-item>

        <el-form-item label="上架状态">
          <el-switch v-model="productForm.active" active-text="上架" inactive-text="下架" />
        </el-form-item>

        <el-form-item label="是否推荐">
          <el-switch v-model="productForm.recommended" active-text="推荐" inactive-text="普通" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="saving" @click="handleSave">保存</el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'

const route = useRoute()
const formRef = ref<FormInstance>()
const saving = ref(false)

const isEdit = computed(() => !!route.params.id)

const categories = ref([
  { id: 1, name: '热菜' },
  { id: 2, name: '凉菜' },
  { id: 3, name: '主食' },
  { id: 4, name: '饮品' },
])

const productForm = reactive({
  name: '',
  categoryId: undefined as number | undefined,
  price: 0,
  originalPrice: 0,
  description: '',
  sortOrder: 0,
  active: true,
  recommended: false,
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入菜品名称', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }],
}

const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => {
    if (!valid) return
    saving.value = true
    // TODO: call product create/update API
    setTimeout(() => {
      saving.value = false
      ElMessage.success(isEdit.value ? '菜品已更新' : '菜品已创建')
    }, 500)
  })
}
</script>
