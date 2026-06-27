import { createRouter, createWebHistory } from 'vue-router'
import { getToken } from '@/utils/auth'

const constantRoutes = [
  { path: '/login', component: () => import('@/views/login/index.vue'), meta: { title: '登录' } },
  {
    path: '/',
    component: () => import('@/layout/index.vue'),
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', component: () => import('@/views/dashboard/index.vue'), meta: { title: '首页' } }
    ]
  }
]

const ownerRoutes = {
  path: '/owner',
  component: () => import('@/layout/index.vue'),
  meta: { title: '业主端', roles: ['0'] },
  children: [
    { path: 'repair', component: () => import('@/views/owner/repair/index.vue'), meta: { title: '报修工单' } },
    { path: 'notice', component: () => import('@/views/owner/notice/index.vue'), meta: { title: '社区公告' } },
    { path: 'outage', component: () => import('@/views/owner/outage/index.vue'), meta: { title: '停水停电' } },
    { path: 'resident', component: () => import('@/views/owner/resident/index.vue'), meta: { title: '住户档案' } },
    { path: 'message', component: () => import('@/views/system/message/index.vue'), meta: { title: '消息中心' } },
    { path: 'profile', component: () => import('@/views/profile/index.vue'), meta: { title: '个人中心' } }
  ]
}

const workerRoutes = {
  path: '/worker',
  component: () => import('@/layout/index.vue'),
  meta: { title: '维修工端', roles: ['1'] },
  children: [
    { path: 'order', component: () => import('@/views/worker/order/index.vue'), meta: { title: '工单作业' } },
    { path: 'message', component: () => import('@/views/system/message/index.vue'), meta: { title: '消息中心' } },
    { path: 'profile', component: () => import('@/views/profile/index.vue'), meta: { title: '个人中心' } }
  ]
}

const propertyRoutes = {
  path: '/property',
  component: () => import('@/layout/index.vue'),
  meta: { title: '物业端', roles: ['2'] },
  children: [
    { path: 'resident', component: () => import('@/views/property/resident/index.vue'), meta: { title: '住户管理' } },
    { path: 'repair', component: () => import('@/views/property/repair/index.vue'), meta: { title: '工单监管' } },
    { path: 'elder', component: () => import('@/views/property/elder/index.vue'), meta: { title: '老人关怀' } },
    { path: 'notice', component: () => import('@/views/property/notice/index.vue'), meta: { title: '公告通知' } },
    { path: 'dashboard', component: () => import('@/views/property/dashboard/index.vue'), meta: { title: '数据大屏' } },
    { path: 'config', component: () => import('@/views/system/config/index.vue'), meta: { title: '系统配置' } },
    { path: 'user', component: () => import('@/views/system/user/index.vue'), meta: { title: '用户管理' } },
    { path: 'loginlog', component: () => import('@/views/system/loginlog/index.vue'), meta: { title: '登录日志' } },
    { path: 'message', component: () => import('@/views/system/message/index.vue'), meta: { title: '消息中心' } },
    { path: 'profile', component: () => import('@/views/profile/index.vue'), meta: { title: '个人中心' } }
  ]
}

const router = createRouter({
  history: createWebHistory(),
  routes: [...constantRoutes, ownerRoutes, workerRoutes, propertyRoutes]
})

router.beforeEach((to, from, next) => {
  if (to.path === '/login') return next()
  if (!getToken()) return next('/login')
  next()
})

export default router
