<template>
  <el-container class="layout-container">
    <el-aside :width="sidebarWidth" class="aside">
      <div class="logo">
        <span v-if="!collapsed" class="logo-title">Smart Care</span>
        <span v-else class="logo-mini">SC</span>
      </div>
      <el-scrollbar class="menu-scroll">
        <el-menu
          :default-active="$route.path"
          :default-openeds="defaultOpeneds"
          :collapse="collapsed"
          router
          background-color="#304156"
          text-color="#bfcbd9"
          active-text-color="#409EFF"
        >
          <template v-for="item in menus" :key="item.path || item.title">
            <el-sub-menu v-if="item.children?.length" :index="item.title">
              <template #title>
                <el-icon><component :is="item.icon" /></el-icon>
                <span>{{ item.title }}</span>
              </template>
              <el-menu-item v-for="child in item.children" :key="child.path" :index="child.path">
                {{ child.title }}
              </el-menu-item>
            </el-sub-menu>
            <el-menu-item v-else :index="item.path">
              <el-icon><component :is="item.icon" /></el-icon>
              <template #title>{{ item.title }}</template>
            </el-menu-item>
          </template>
        </el-menu>
      </el-scrollbar>
    </el-aside>
    <el-container class="main-wrap">
      <el-header class="navbar">
        <div class="navbar-left">
          <el-icon class="hamburger" @click="collapsed = !collapsed"><Fold /></el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>{{ roleLabel }}</el-breadcrumb-item>
            <el-breadcrumb-item v-if="$route.meta.parent">{{ $route.meta.parent }}</el-breadcrumb-item>
            <el-breadcrumb-item>{{ $route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="navbar-right">
          <el-dropdown trigger="click" @command="handleCommand">
            <div class="user-info">
              <el-avatar :size="32" :src="avatarSrc">{{ avatarText }}</el-avatar>
              <span class="nick-name">{{ userStore.nickName || userStore.user?.username }}</span>
              <el-icon class="arrow"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>个人中心
                </el-dropdown-item>
                <el-dropdown-item divided command="logout">
                  <el-icon><SwitchButton /></el-icon>退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="app-main">
        <router-view :key="$route.fullPath" />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { ArrowDown, User, SwitchButton, Fold } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const router = useRouter()
const collapsed = ref(false)

const sidebarWidth = computed(() => (collapsed.value ? '64px' : '210px'))

const roleMap = { '0': '业主端', '1': '维修工端', '2': '物业端' }
const roleLabel = computed(() => roleMap[userStore.userType] || '')

const profilePathMap = { '0': '/owner/profile', '1': '/worker/profile', '2': '/property/profile' }

const menuMap = {
  '0': [
    { path: '/owner/repair', title: '报修工单', icon: 'Tools' },
    { path: '/owner/notice', title: '社区公告', icon: 'Bell' },
    { path: '/owner/outage', title: '停水停电', icon: 'Warning' },
    { path: '/owner/resident', title: '住户档案', icon: 'User' },
    { path: '/owner/assistant', title: '智能问答', icon: 'ChatDotRound' }
  ],
  '1': [
    { path: '/worker/order', title: '工单作业', icon: 'Tools' },
    { path: '/worker/order/messages', title: '消息通知', icon: 'Bell' },
    { path: '/worker/order/knowledge', title: '维修知识库', icon: 'Reading' }
  ],
  '2': [
    { path: '/property/dashboard', title: '数据大屏', icon: 'DataAnalysis' },
    {
      title: '社区资源',
      icon: 'OfficeBuilding',
      children: [
        { path: '/property/building', title: '楼栋管理' },
        { path: '/property/house', title: '房屋管理' },
        { path: '/property/resident', title: '住户档案' }
      ]
    },
    { path: '/property/repair', title: '工单监管', icon: 'Tools' },
    { path: '/property/repair/ai-report', title: 'AI复盘周报', icon: 'DataAnalysis' },
    { path: '/property/repair/ai-trend', title: '服务质量趋势', icon: 'TrendCharts' },
    { path: '/property/elder', title: '老人关怀', icon: 'FirstAidKit' },
    {
      title: 'AI智能问答管理',
      icon: 'ChatDotRound',
      children: [
        { path: '/property/ai/knowledge', title: '知识库管理' },
        { path: '/property/ai/knowledge-learn', title: '知识库自学习' },
        { path: '/property/ai/chat-active', title: '待处理对话' },
        { path: '/property/ai/chat-history', title: '历史对话' }
      ]
    },
    {
      title: '公告通知',
      icon: 'Bell',
      children: [
        { path: '/property/notice/announce', title: '社区公告' },
        { path: '/property/notice/outage', title: '停水停电' }
      ]
    },
    { path: '/property/config', title: '系统配置', icon: 'Setting' },
    { path: '/property/user', title: '用户管理', icon: 'UserFilled' }
  ]
}

const defaultOpeneds = computed(() => {
  const type = userStore.userType
  if (type === '2') return ['社区资源', '公告通知', 'AI智能问答管理']
  return []
})

const menus = computed(() => menuMap[userStore.userType] || [])

const avatarSrc = computed(() => {
  const av = userStore.user?.avatar
  if (!av) return ''
  if (av.startsWith('http') || av.startsWith('data:')) return av
  return '/api' + av
})

const avatarText = computed(() => {
  const name = userStore.nickName || userStore.user?.username || 'U'
  return name.charAt(0).toUpperCase()
})

function handleCommand(cmd) {
  if (cmd === 'profile') {
    const path = profilePathMap[userStore.userType]
    if (path) router.push(path)
  } else if (cmd === 'logout') {
    confirmLogout()
  }
}

function confirmLogout() {
  ElMessageBox.confirm('确定退出系统吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    userStore.logout()
    router.push('/login')
  }).catch(() => {})
}

onMounted(() => {
  if (userStore.token && !userStore.user?.userId) {
    userStore.fetchInfo().catch(() => {})
  }
})
</script>

<style scoped lang="scss">
.layout-container { height: 100vh; }
.aside {
  background: #304156;
  transition: width 0.2s;
  overflow: hidden;
}
.logo {
  height: 50px;
  line-height: 50px;
  text-align: center;
  background: #2b2f3a;
  color: #fff;
  font-weight: 600;
  font-size: 16px;
  .logo-mini { font-size: 14px; }
}
.menu-scroll {
  height: calc(100vh - 50px);
  :deep(.el-menu) { border-right: none; }
}
.main-wrap { flex-direction: column; background: #f0f2f5; }
.navbar {
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}
.navbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}
.hamburger {
  font-size: 20px;
  cursor: pointer;
  color: #5a5e66;
  &:hover { color: #409EFF; }
}
.navbar-right {
  display: flex;
  align-items: center;
  :deep(.el-dropdown) { line-height: normal; }
}
.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  outline: none;
  .nick-name {
    font-size: 14px;
    color: #606266;
    max-width: 120px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .arrow { color: #909399; font-size: 12px; }
}
.app-main {
  padding: 0;
  overflow: auto;
}
</style>
