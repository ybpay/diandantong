import { createRouter, createWebHashHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Shop from '../views/Shop.vue'
import Kitchen from '../views/Kitchen.vue'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login,
      meta: { requiresAuth: false },
    },
    {
      path: '/shop',
      name: 'shop',
      component: Shop,
      meta: { requiresAuth: true },
    },
    {
      path: '/branches/:branchId/kitchen',
      name: 'kitchen',
      component: Kitchen,
      meta: { requiresAuth: true },
    },
    {
      path: '/',
      redirect: '/login',
    },
  ],
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
