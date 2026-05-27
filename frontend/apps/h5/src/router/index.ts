import { createRouter, createWebHashHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/auth',
    name: 'auth',
    component: () => import('../views/auth/Auth.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/home',
    name: 'home',
    component: () => import('../views/home/Home.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/menu/:branchId',
    name: 'menu',
    component: () => import('../views/menu/Index.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/menu/:branchId/product/:productId',
    name: 'productDetail',
    component: () => import('../views/menu/ProductDetail.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/cart',
    name: 'cart',
    component: () => import('../views/cart/Cart.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/order/confirm',
    name: 'orderConfirm',
    component: () => import('../views/order/Confirm.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/order/success',
    name: 'orderSuccess',
    component: () => import('../views/order/Success.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/orders',
    name: 'orders',
    component: () => import('../views/orders/Orders.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/orders/:id',
    name: 'orderDetail',
    component: () => import('../views/order/Detail.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/queue/:branchId',
    name: 'queue',
    component: () => import('../views/queue/Index.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/queue/:branchId/status',
    name: 'queueStatus',
    component: () => import('../views/queue/Status.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/pay/:orderId',
    name: 'pay',
    component: () => import('../views/pay/Pay.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/vip',
    name: 'vip',
    component: () => import('../views/vip/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/vip/recharge',
    name: 'vipRecharge',
    component: () => import('../views/vip/Recharge.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/vip/coupons',
    name: 'vipCoupons',
    component: () => import('../views/vip/Coupons.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/profile',
    name: 'profile',
    component: () => import('../views/profile/Profile.vue'),
    meta: { requiresAuth: true },
  },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('h5_auth_token')
  if (to.meta.requiresAuth && !token) {
    next({ name: 'auth' })
  } else {
    next()
  }
})

export default router
