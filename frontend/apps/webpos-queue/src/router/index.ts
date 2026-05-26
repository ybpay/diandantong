import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/shop',
    name: 'Shop',
    component: () => import('@/views/Shop.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/queue',
    name: 'Queue',
    component: () => import('@/views/Queue.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/',
    redirect: '/login',
  },
]

const router = createRouter({
  history: createWebHistory('/webpos_queue/'),
  routes,
})

// Navigation guard for auth
router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('auth_token')

  if (to.meta.requiresAuth && !token) {
    next({ name: 'Login' })
  } else if (to.name === 'Login' && token) {
    next({ name: 'Shop' })
  } else {
    next()
  }
})

export default router
