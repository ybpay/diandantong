import { createRouter, createWebHashHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/',
    name: 'shop',
    component: () => import('../views/Shop.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/users',
    name: 'users',
    component: () => import('../views/Users.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/users/:vipInfoId',
    name: 'userDetail',
    component: () => import('../views/UserDetail.vue'),
    meta: { requiresAuth: true },
  },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('auth_token')
  if (to.meta.requiresAuth && !token) {
    next({ name: 'login' })
  } else if (to.name === 'login' && token) {
    next({ name: 'shop' })
  } else {
    next()
  }
})

export default router
