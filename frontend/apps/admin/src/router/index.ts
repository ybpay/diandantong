import { createRouter, createWebHashHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import AdminLayout from '../layouts/AdminLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/',
    component: AdminLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'dashboard',
        component: () => import('../views/Dashboard.vue'),
      },
      // Shop settings
      {
        path: 'shop',
        name: 'shop',
        component: () => import('../views/shop/Index.vue'),
      },
      {
        path: 'branches',
        name: 'branches',
        component: () => import('../views/branches/Index.vue'),
      },
      {
        path: 'branches/:id',
        name: 'branchDetail',
        component: () => import('../views/branches/Detail.vue'),
      },
      // Product management
      {
        path: 'products',
        name: 'products',
        component: () => import('../views/products/Index.vue'),
      },
      {
        path: 'products/new',
        name: 'productNew',
        component: () => import('../views/products/Form.vue'),
      },
      {
        path: 'products/:id/edit',
        name: 'productEdit',
        component: () => import('../views/products/Form.vue'),
      },
      {
        path: 'categories',
        name: 'categories',
        component: () => import('../views/products/Categories.vue'),
      },
      {
        path: 'combos',
        name: 'combos',
        component: () => import('../views/products/Combos.vue'),
      },
      // Order management
      {
        path: 'orders',
        name: 'orders',
        component: () => import('../views/orders/Index.vue'),
      },
      {
        path: 'orders/eat-in-hall',
        name: 'eatInHallOrders',
        component: () => import('../views/orders/EatInHall.vue'),
      },
      {
        path: 'orders/delivery',
        name: 'deliveryOrders',
        component: () => import('../views/orders/Delivery.vue'),
      },
      {
        path: 'orders/fastfood',
        name: 'fastFoodOrders',
        component: () => import('../views/orders/FastFood.vue'),
      },
      {
        path: 'orders/groupon',
        name: 'grouponOrders',
        component: () => import('../views/orders/Groupon.vue'),
      },
      {
        path: 'orders/reservation',
        name: 'reservationOrders',
        component: () => import('../views/orders/Reservation.vue'),
      },
      {
        path: 'orders/recharge',
        name: 'rechargeOrders',
        component: () => import('../views/orders/Recharge.vue'),
      },
      {
        path: 'orders/payment',
        name: 'paymentOrders',
        component: () => import('../views/orders/Payment.vue'),
      },
      {
        path: 'orders/:id',
        name: 'orderDetail',
        component: () => import('../views/orders/Detail.vue'),
      },
      // CRM - VIP management
      {
        path: 'vip',
        name: 'vip',
        component: () => import('../views/crm/vip/Index.vue'),
      },
      {
        path: 'vip/levels',
        name: 'vipLevels',
        component: () => import('../views/crm/vip/Levels.vue'),
      },
      {
        path: 'vip/settings',
        name: 'vipSettings',
        component: () => import('../views/crm/vip/Settings.vue'),
      },
      // CRM - Coupons
      {
        path: 'coupons',
        name: 'coupons',
        component: () => import('../views/crm/coupons/Index.vue'),
      },
      {
        path: 'coupons/versions',
        name: 'couponVersions',
        component: () => import('../views/crm/coupons/Versions.vue'),
      },
      {
        path: 'coupons/settings',
        name: 'couponSettings',
        component: () => import('../views/crm/coupons/Settings.vue'),
      },
      // CRM - Recharge
      {
        path: 'recharge',
        name: 'recharge',
        component: () => import('../views/crm/recharge/Index.vue'),
      },
      {
        path: 'recharge/settings',
        name: 'rechargeSettings',
        component: () => import('../views/crm/recharge/Settings.vue'),
      },
      // CRM - Credits
      {
        path: 'credits',
        name: 'credits',
        component: () => import('../views/crm/credits/Index.vue'),
      },
      // Marketing - Promotions
      {
        path: 'promotions',
        name: 'promotions',
        component: () => import('../views/marketing/promotions/Index.vue'),
      },
      {
        path: 'promotions/new',
        name: 'promotionNew',
        component: () => import('../views/marketing/promotions/Form.vue'),
      },
      {
        path: 'promotions/:id/edit',
        name: 'promotionEdit',
        component: () => import('../views/marketing/promotions/Form.vue'),
      },
      // Marketing - Groupon vouchers
      {
        path: 'groupons',
        name: 'groupons',
        component: () => import('../views/marketing/groupons/Index.vue'),
      },
      // Marketing - Vouchers
      {
        path: 'vouchers',
        name: 'vouchers',
        component: () => import('../views/marketing/vouchers/Index.vue'),
      },
      // Statistics
      {
        path: 'statistics',
        name: 'statistics',
        component: () => import('../views/statistics/Index.vue'),
      },
      {
        path: 'statistics/business',
        name: 'businessStatistics',
        component: () => import('../views/statistics/Business.vue'),
      },
      {
        path: 'statistics/orders',
        name: 'orderStatistics',
        component: () => import('../views/statistics/Orders.vue'),
      },
      {
        path: 'statistics/products',
        name: 'productStatistics',
        component: () => import('../views/statistics/Products.vue'),
      },
      {
        path: 'statistics/finance',
        name: 'financeStatistics',
        component: () => import('../views/statistics/Finance.vue'),
      },
      {
        path: 'statistics/coupons',
        name: 'couponStatistics',
        component: () => import('../views/statistics/Coupons.vue'),
      },
      {
        path: 'statistics/workers',
        name: 'workerStatistics',
        component: () => import('../views/statistics/Workers.vue'),
      },
      // Printers
      {
        path: 'printers',
        name: 'printers',
        component: () => import('../views/printers/Index.vue'),
      },
      // Queue
      {
        path: 'queue',
        name: 'queue',
        component: () => import('../views/queue/Index.vue'),
      },
      // Settings
      {
        path: 'settings',
        name: 'settings',
        component: () => import('../views/settings/Index.vue'),
      },
      {
        path: 'settings/roles',
        name: 'roles',
        component: () => import('../views/settings/Roles.vue'),
      },
      {
        path: 'settings/accounts',
        name: 'accounts',
        component: () => import('../views/settings/Accounts.vue'),
      },
      {
        path: 'settings/tables',
        name: 'tableSettings',
        component: () => import('../views/settings/Tables.vue'),
      },
      {
        path: 'settings/wechat',
        name: 'wechatSettings',
        component: () => import('../views/settings/Wechat.vue'),
      },
      {
        path: 'settings/payment',
        name: 'paymentSettings',
        component: () => import('../views/settings/Payment.vue'),
      },
      {
        path: 'settings/delivery',
        name: 'deliverySettings',
        component: () => import('../views/settings/Delivery.vue'),
      },
      {
        path: 'settings/print',
        name: 'printSettings',
        component: () => import('../views/settings/Print.vue'),
      },
    ],
  },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('admin_auth_token')
  if (to.meta.requiresAuth && !token) {
    next({ name: 'login' })
  } else if (to.name === 'login' && token) {
    next({ name: 'dashboard' })
  } else {
    next()
  }
})

export default router
