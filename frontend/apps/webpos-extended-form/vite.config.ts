import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue(), tailwindcss()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@webpos/ui': resolve(__dirname, '../../packages/ui/src'),
      '@webpos/composables': resolve(__dirname, '../../packages/composables/src'),
      '@webpos/api': resolve(__dirname, '../../packages/api/src'),
      '@webpos/stores': resolve(__dirname, '../../packages/stores/src'),
      '@webpos/types': resolve(__dirname, '../../packages/types/src'),
    },
  },
  server: {
    port: 3007,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
      '/cable': {
        target: 'ws://localhost:3000',
        ws: true,
      },
    },
  },
  build: {
    outDir: '../../../public/webpos_extended_form',
    emptyOutDir: true,
  },
})
