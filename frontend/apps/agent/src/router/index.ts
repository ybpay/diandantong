import { createRouter, createWebHashHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import AgentLayout from '../layouts/AgentLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/',
    component: AgentLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'dashboard',
        component: () => import('../views/Dashboard.vue'),
        meta: { title: '控制台' },
      },
      {
        path: 'merchants',
        name: 'merchants',
        component: () => import('../views/merchants/Index.vue'),
        meta: { title: '商户列表' },
      },
      {
        path: 'merchants/:id',
        name: 'merchantDetail',
        component: () => import('../views/merchants/Detail.vue'),
        meta: { title: '商户详情' },
      },
      {
        path: 'merchants/new',
        name: 'merchantNew',
        component: () => import('../views/merchants/Form.vue'),
        meta: { title: '新建商户' },
      },
      {
        path: 'expirations',
        name: 'expirations',
        component: () => import('../views/Expirations.vue'),
        meta: { title: '到期管理' },
      },
      {
        path: 'brands',
        name: 'brands',
        component: () => import('../views/brands/Index.vue'),
        meta: { title: '品牌配置' },
      },
      {
        path: 'brands/:id',
        name: 'brandDetail',
        component: () => import('../views/brands/Detail.vue'),
        meta: { title: '品牌详情' },
      },
      {
        path: 'oem',
        name: 'oem',
        component: () => import('../views/oem/Index.vue'),
        meta: { title: 'OEM设置' },
      },
      {
        path: 'agents',
        name: 'agents',
        component: () => import('../views/agents/Index.vue'),
        meta: { title: '子代理管理' },
      },
      {
        path: 'statistics',
        name: 'statistics',
        component: () => import('../views/statistics/Index.vue'),
        meta: { title: '数据统计' },
      },
      {
        path: 'settings',
        name: 'settings',
        component: () => import('../views/settings/Index.vue'),
        meta: { title: '系统设置' },
      },
    ],
  },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('agent_auth_token')
  if (to.meta.requiresAuth && !token) {
    next({ name: 'login' })
  } else if (to.name === 'login' && token) {
    next({ name: 'dashboard' })
  } else {
    next()
  }
})

export default router
