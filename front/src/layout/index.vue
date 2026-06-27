<template>
  <el-container class="layout-container">
    <el-aside width="220px" class="aside">
      <div class="logo">
        <h2>Smart Care Community</h2>
        <span>{{ roleLabel }}</span>
      </div>
      <el-menu :default-active="$route.path" router background-color="#1a5f4a" text-color="#fff" active-text-color="#ffd04b">
        <el-menu-item v-for="item in menus" :key="item.path" :index="item.path">
          <el-icon><component :is="item.icon" /></el-icon>
          <span>{{ item.title }}</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="header">
        <span class="page-title">{{ $route.meta.title }}</span>
        <div class="header-right">
          <el-dropdown trigger="click" @command="handleCommand">
            <div class="user-info">
              <el-avatar :size="36" :src="avatarSrc">{{ avatarText }}</el-avatar>
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
      <el-main><router-view /></el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { ArrowDown, User, SwitchButton } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const route = useRoute()
const router = useRouter()

const roleMap = { '0': '业主端', '1': '维修工端', '2': '物业端' }
const roleLabel = computed(() => roleMap[userStore.userType] || '')

const profilePathMap = { '0': '/owner/profile', '1': '/worker/profile', '2': '/property/profile' }

const menuMap = {
  '0': [
    { path: '/owner/repair', title: '报修工单', icon: 'Tools' },
    { path: '/owner/notice', title: '社区公告', icon: 'Bell' },
    { path: '/owner/outage', title: '停水停电', icon: 'Warning' },
    { path: '/owner/resident', title: '住户档案', icon: 'User' },
    { path: '/owner/message', title: '消息中心', icon: 'Message' }
  ],
  '1': [
    { path: '/worker/order', title: '工单作业', icon: 'Tools' },
    { path: '/worker/message', title: '消息中心', icon: 'Message' }
  ],
  '2': [
    { path: '/property/dashboard', title: '数据大屏', icon: 'DataAnalysis' },
    { path: '/property/resident', title: '社区资源', icon: 'OfficeBuilding' },
    { path: '/property/repair', title: '工单监管', icon: 'Tools' },
    { path: '/property/elder', title: '老人关怀', icon: 'FirstAidKit' },
    { path: '/property/notice', title: '公告通知', icon: 'Bell' },
    { path: '/property/config', title: '系统配置', icon: 'Setting' },
    { path: '/property/user', title: '用户管理', icon: 'UserFilled' },
    { path: '/property/loginlog', title: '登录日志', icon: 'Document' },
    { path: '/property/message', title: '消息中心', icon: 'Message' }
  ]
}

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
  ElMessageBox.confirm('确定注销并退出系统吗？', '提示', {
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
.aside { background: #1a5f4a; }
.logo {
  padding: 20px; color: #fff; text-align: center;
  h2 { font-size: 18px; margin: 0; }
  span { font-size: 12px; opacity: .8; }
}
.header {
  display: flex; justify-content: space-between; align-items: center;
  background: #fff; border-bottom: 1px solid #eee;
  padding: 0 20px;
  .page-title { font-size: 16px; font-weight: 500; color: #303133; }
}
.header-right {
  display: flex; align-items: center;
  :deep(.el-dropdown) {
    line-height: normal;
  }
}
.user-info {
  display: flex; align-items: center; gap: 8px; cursor: pointer;
  outline: none; line-height: normal;
  .nick-name {
    font-size: 14px;
    line-height: 22px;
    color: #303133;
    max-width: 120px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    min-width: 0;
  }
  .arrow { color: #909399; font-size: 12px; flex-shrink: 0; }
}
</style>
