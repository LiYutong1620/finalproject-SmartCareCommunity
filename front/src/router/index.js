import { createRouter, createWebHistory } from 'vue-router'
import { getToken, getRoleHome } from '@/utils/auth'

const constantRoutes = [
  { path: '/login', component: () => import('@/views/login/index.vue'), meta: { title: '登录' } },
  {
    path: '/',
    redirect: () => (getToken() ? getRoleHome() : '/login')
  }
]

const ownerRoutes = {
  path: '/owner',
  component: () => import('@/layout/index.vue'),
  meta: { title: '业主端', roles: ['0'] },
  children: [
    { path: 'repair', component: () => import('@/views/owner/repair/index.vue'), meta: { title: '报修工单' } },
    { path: 'repair/accept/:orderId', component: () => import('@/views/owner/repair/accept.vue'), meta: { title: '验收工单' } }, // 喵
    { path: 'repair/detail/:orderId', component: () => import('@/views/owner/repair/detail.vue'), meta: { title: '工单进度' } }, // 喵
    { path: 'notice', component: () => import('@/views/owner/notice/index.vue'), meta: { title: '社区公告' } },
    { path: 'notice/detail/:id', component: () => import('@/views/owner/notice/detail.vue'), meta: { title: '公告详情' } },
    { path: 'outage', component: () => import('@/views/owner/outage/index.vue'), meta: { title: '停水停电' } },
    { path: 'outage/detail/:id', component: () => import('@/views/owner/outage/detail.vue'), meta: { title: '通知详情' } },
    { path: 'resident', component: () => import('@/views/owner/resident/index.vue'), meta: { title: '住户档案' } },
    { path: 'assistant', component: () => import('@/views/owner/assistant/index.vue'), meta: { title: '智能问答' } },
    { path: 'profile', component: () => import('@/views/profile/index.vue'), meta: { title: '个人中心' } }
  ]
}

const workerRoutes = {
  path: '/worker',
  component: () => import('@/layout/index.vue'),
  meta: { title: '维修工端', roles: ['1'] },
  children: [
    { path: 'order', component: () => import('@/views/worker/order/index.vue'), meta: { title: '工单作业' } },
    { path: 'order/profile', component: () => import('@/views/worker/order/profile.vue'), meta: { title: '个人状态' } },
    { path: 'order/messages', component: () => import('@/views/worker/order/messages.vue'), meta: { title: '消息通知' } },
    { path: 'order/knowledge', component: () => import('@/views/worker/order/knowledge.vue'), meta: { title: '维修知识库' } },
    { path: 'profile', component: () => import('@/views/profile/index.vue'), meta: { title: '个人中心' } }
  ]
}

const propertyRoutes = {
  path: '/property',
  component: () => import('@/layout/index.vue'),
  meta: { title: '物业端', roles: ['2'] },
  children: [
    { path: 'building', component: () => import('@/views/property/building/index.vue'), meta: { title: '楼栋管理', parent: '社区资源' } },
    { path: 'house', component: () => import('@/views/property/house/index.vue'), meta: { title: '房屋管理', parent: '社区资源' } },
    { path: 'resident', component: () => import('@/views/property/resident/index.vue'), meta: { title: '住户档案', parent: '社区资源' } },
    { path: 'repair', component: () => import('@/views/property/repair/index.vue'), meta: { title: '工单监管' } },
    { path: 'repair/detail/:orderId', component: () => import('@/views/property/repair/detail.vue'), meta: { title: '工单详情' } },
    { path: 'repair/type-manage', component: () => import('@/views/property/repair/type-manage.vue'), meta: { title: '报修类型管理' } },
    { path: 'repair/ai-report', component: () => import('@/views/property/repair/ai-report.vue'), meta: { title: 'AI复盘周报' } },
    { path: 'repair/ai-trend', component: () => import('@/views/property/repair/ai-trend.vue'), meta: { title: '服务质量趋势' } },
    { path: 'elder', component: () => import('@/views/property/elder/index.vue'), meta: { title: '老人关怀' } },
    { path: 'notice/announce', component: () => import('@/views/property/notice/index.vue'), meta: { title: '社区公告', noticeType: 'announce', parent: '公告通知' } },
    { path: 'notice/outage', component: () => import('@/views/property/notice/index.vue'), meta: { title: '停水停电', noticeType: 'outage', parent: '公告通知' } },
    { path: 'notice', redirect: '/property/notice/announce' },
    { path: 'ai', redirect: '/property/ai/knowledge' },
    { path: 'ai/knowledge', component: () => import('@/views/property/ai/knowledge.vue'), meta: { title: '知识库管理', parent: 'AI智能问答管理' } },
    { path: 'ai/knowledge-learn', component: () => import('@/views/property/ai/knowledge-learn.vue'), meta: { title: '知识库自学习', parent: 'AI智能问答管理' } },
    { path: 'ai/chat-active', component: () => import('@/views/property/ai/chat-session-list.vue'), meta: { title: '待处理对话', mode: 'active', parent: 'AI智能问答管理' } },
    { path: 'ai/chat-history', component: () => import('@/views/property/ai/chat-session-list.vue'), meta: { title: '历史对话', mode: 'history', parent: 'AI智能问答管理' } },
    { path: 'ai/chat-list', redirect: '/property/ai/chat-active' },
    { path: 'ai/chat/:sessionId', component: () => import('@/views/property/ai/chat.vue'), meta: { title: '对话详情', parent: 'AI智能问答管理' } },
    { path: 'dashboard', component: () => import('@/views/property/dashboard/index.vue'), meta: { title: '数据大屏' } },
    { path: 'config', component: () => import('@/views/system/config/index.vue'), meta: { title: '系统配置' } },
    { path: 'user', component: () => import('@/views/system/user/index.vue'), meta: { title: '用户管理' } },
    { path: 'profile', component: () => import('@/views/profile/index.vue'), meta: { title: '个人中心' } }
  ]
}

const router = createRouter({
  history: createWebHistory(),
  routes: [...constantRoutes, ownerRoutes, workerRoutes, propertyRoutes]
})

router.beforeEach((to, from, next) => {
  const token = getToken()
  const home = getRoleHome()

  // 已登录访问登录页 → 进入对应角色首页
  if (to.path === '/login') {
    return token ? next(home) : next()
  }

  // 未登录 → 登录页
  if (!token) {
    return next('/login')
  }

  // 已登录访问根路径或旧通用首页 → 角色首页
  if (to.path === '/' || to.path === '/dashboard') {
    return next(home)
  }

  next()
})

export default router
