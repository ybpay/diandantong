import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue(), tailwindcss()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@diandantong/admin-api': resolve(__dirname, '../../packages/admin-api/src'),
      '@diandantong/admin-stores': resolve(__dirname, '../../packages/admin-stores/src'),
      '@diandantong/admin-types': resolve(__dirname, '../../packages/admin-types/src'),
    },
  },
  server: {
    port: 3002,
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
    outDir: '../../../public/admin',
    emptyOutDir: true,
  },
})
