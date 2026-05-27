import { createRouter, createWebHashHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/sign_in',
    name: 'signIn',
    component: () => import('../views/account/SignIn.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/',
    name: 'shop',
    component: () => import('../views/shop/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/eat_in_hall',
    name: 'eatInHall',
    component: () => import('../views/branches/EatInHall.vue'),
    meta: { requiresAuth: true, orderType: 'eat_in_hall' },
  },
  {
    path: '/branches/:branchId/delivery',
    name: 'delivery',
    component: () => import('../views/branches/Delivery.vue'),
    meta: { requiresAuth: true, orderType: 'delivery' },
  },
  {
    path: '/branches/:branchId/reservation',
    name: 'reservation',
    component: () => import('../views/branches/Reservation.vue'),
    meta: { requiresAuth: true, orderType: 'reservation' },
  },
  {
    path: '/branches/:branchId/fast_food',
    name: 'fastFood',
    component: () => import('../views/branches/FastFood.vue'),
    meta: { requiresAuth: true, orderType: 'fast_food' },
  },
  {
    path: '/branches/:branchId/payment',
    name: 'payment',
    component: () => import('../views/branches/Payment.vue'),
    meta: { requiresAuth: true, orderType: 'payment' },
  },
  {
    path: '/branches/:branchId/tables/:tableId/cart',
    name: 'tableCart',
    component: () => import('../views/tables/Cart.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/tables/:tableId/order',
    name: 'tableOrder',
    component: () => import('../views/tables/Order.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/orders',
    name: 'orders',
    component: () => import('../views/orders/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/orders/:orderId/settle/:orderType',
    name: 'orderSettle',
    component: () => import('../views/orders/Settle.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/vip_infos',
    name: 'vipInfos',
    component: () => import('../views/vip_infos/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/vip_infos',
    name: 'allVipInfos',
    component: () => import('../views/vip_infos/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/statistics',
    name: 'statistics',
    component: () => import('../views/statistics/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/guest_queues',
    name: 'guestQueues',
    component: () => import('../views/guest_queues/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/promotions',
    name: 'promotions',
    component: () => import('../views/promotions/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/estimate_clear',
    name: 'estimateClear',
    component: () => import('../views/estimate_clear/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/printers',
    name: 'printers',
    component: () => import('../views/printers/Index.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/branches/:branchId/bill_center',
    name: 'billCenter',
    component: () => import('../views/bills/BillCenter.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/settings',
    name: 'settings',
    component: () => import('../views/settings/Index.vue'),
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
    next({ name: 'signIn' })
  } else if (to.name === 'signIn' && token) {
    next({ name: 'shop' })
  } else {
    next()
  }
})

export default router
