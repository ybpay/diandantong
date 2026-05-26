import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Shop from '../views/Shop.vue'
import Kitchen from '../views/Kitchen.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login,
    },
    {
      path: '/shop',
      name: 'shop',
      component: Shop,
    },
    {
      path: '/branches/:branchId/kitchen',
      name: 'kitchen',
      component: Kitchen,
    },
    {
      path: '/',
      redirect: '/login',
    },
  ],
})

export default router
