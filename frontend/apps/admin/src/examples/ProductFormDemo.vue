<script setup lang="ts">
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { z } from 'zod'

// Define validation schema with Zod
const productSchema = toTypedSchema(
  z.object({
    name: z.string().min(1, 'Product name is required').max(100, 'Name too long'),
    price: z
      .number({ invalid_type_error: 'Price must be a number' })
      .positive('Price must be positive')
      .max(99999, 'Price too high'),
    category_id: z.number({ required_error: 'Category is required' }).int().positive(),
    description: z.string().max(500, 'Description too long').optional(),
    is_active: z.boolean().default(true),
  }),
)

const { handleSubmit, errors, defineField, resetForm } = useForm({
  validationSchema: productSchema,
  initialValues: {
    name: '',
    price: undefined,
    category_id: undefined,
    description: '',
    is_active: true,
  },
})

const [name, nameAttrs] = defineField('name')
const [price, priceAttrs] = defineField('price')
const [categoryId, categoryIdAttrs] = defineField('category_id')
const [description, descriptionAttrs] = defineField('description')
const [isActive, isActiveAttrs] = defineField('is_active')

const onSubmit = handleSubmit((values) => {
  console.log('Form submitted:', values)
  alert(`Product created: ${values.name}`)
  resetForm()
})
</script>

<template>
  <div class="mx-auto max-w-lg p-6">
    <h2 class="mb-4 text-xl font-bold">VeeValidate + Zod Form Demo</h2>

    <form @submit="onSubmit" class="space-y-4">
      <div>
        <label class="mb-1 block text-sm font-medium text-gray-700">Product Name</label>
        <input
          v-model="name"
          v-bind="nameAttrs"
          type="text"
          class="w-full rounded border px-3 py-2"
          placeholder="Enter product name"
        />
        <p v-if="errors.name" class="mt-1 text-sm text-red-600">{{ errors.name }}</p>
      </div>

      <div>
        <label class="mb-1 block text-sm font-medium text-gray-700">Price (CNY)</label>
        <input
          v-model="price"
          v-bind="priceAttrs"
          type="number"
          step="0.01"
          class="w-full rounded border px-3 py-2"
          placeholder="0.00"
        />
        <p v-if="errors.price" class="mt-1 text-sm text-red-600">{{ errors.price }}</p>
      </div>

      <div>
        <label class="mb-1 block text-sm font-medium text-gray-700">Category</label>
        <select
          v-model="categoryId"
          v-bind="categoryIdAttrs"
          class="w-full rounded border px-3 py-2"
        >
          <option :value="undefined" disabled>Select category</option>
          <option :value="1">Hot Dishes</option>
          <option :value="2">Cold Dishes</option>
          <option :value="3">Drinks</option>
          <option :value="4">Snacks</option>
        </select>
        <p v-if="errors.category_id" class="mt-1 text-sm text-red-600">
          {{ errors.category_id }}
        </p>
      </div>

      <div>
        <label class="mb-1 block text-sm font-medium text-gray-700">Description</label>
        <textarea
          v-model="description"
          v-bind="descriptionAttrs"
          class="w-full rounded border px-3 py-2"
          rows="3"
          placeholder="Optional description"
        />
        <p v-if="errors.description" class="mt-1 text-sm text-red-600">
          {{ errors.description }}
        </p>
      </div>

      <div class="flex items-center gap-2">
        <input v-model="isActive" v-bind="isActiveAttrs" type="checkbox" class="rounded" />
        <label class="text-sm font-medium text-gray-700">Active</label>
      </div>

      <div class="flex gap-3">
        <button
          type="submit"
          class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
        >
          Create Product
        </button>
        <button
          type="button"
          class="rounded bg-gray-200 px-4 py-2 text-gray-700 hover:bg-gray-300"
          @click="resetForm()"
        >
          Reset
        </button>
      </div>
    </form>
  </div>
</template>
