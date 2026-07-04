<template>
  <el-container class="layout-container" :class="roleThemeClass">
    <el-aside :width="sidebarWidth" class="aside">
      <div class="logo">
        <AppLogo :size="32" :collapsed="collapsed" theme="light" />
      </div>
      <el-scrollbar class="menu-scroll">
        <el-menu
          :default-active="$route.path"
          :default-openeds="defaultOpeneds"
          :collapse="collapsed"
          router
          background-color="transparent"
          text-color="var(--brand-sidebar-text)"
          active-text-color="var(--brand-sidebar-text-active)"
        >
          <template v-for="item in menus" :key="item.path || item.title">
            <el-sub-menu v-if="item.children?.length" :index="item.title">
              <template #title>
                <el-icon><component :is="item.icon" /></el-icon>
                <span>{{ item.title }}</span>
              </template>
              <el-menu-item
                v-for="child in item.children"
                :key="child.path"
                :index="child.path"
              >
                <template #title>{{ child.title }}</template>
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
          <el-icon class="hamburger" @click="collapsed = !collapsed">
            <component :is="collapsed ? 'Expand' : 'Fold'" />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>{{ roleLabel }}</el-breadcrumb-item>
            <el-breadcrumb-item v-if="$route.meta.parent">{{
              $route.meta.parent
            }}</el-breadcrumb-item>
            <el-breadcrumb-item>{{ $route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="navbar-right">
          <el-dropdown trigger="click" @command="handleCommand">
            <div class="user-info">
              <el-avatar
                :size="30"
                :src="avatarSrc"
                :style="avatarFallbackStyle"
              >{{ avatarText }}</el-avatar>
              <span class="nick-name">{{
                userStore.nickName || userStore.user?.username
              }}</span>
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
      <el-main class="app-main" :class="{ 'app-main--full': route.meta.fullHeight }">
        <router-view :key="$route.fullPath" />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useRouter, useRoute } from "vue-router";
import { ElMessageBox } from "element-plus";
import {
  ArrowDown,
  User,
  SwitchButton,
  Fold,
  Expand,
} from "@element-plus/icons-vue";
import { useUserStore } from "@/store/user";
import AppLogo from "@/components/AppLogo.vue";
import { getRoleAvatarColor } from "@/utils/avatar";
import { getRoleThemeClass } from "@/constants/brand";

const userStore = useUserStore();
const router = useRouter();
const route = useRoute();
const collapsed = ref(false);

const sidebarWidth = computed(() => (collapsed.value ? "64px" : "210px"));

const roleMap = { 0: "业主端", 1: "维修工端", 2: "物业端" };
const roleLabel = computed(() => roleMap[userStore.userType] || "");

const roleThemeClass = computed(() => getRoleThemeClass(userStore.userType));

const profilePathMap = {
  0: "/owner/profile",
  1: "/worker/profile",
  2: "/property/profile",
};

const menuMap = {
  0: [
    { path: "/owner/repair", title: "报修工单", icon: "Tools" },
    { path: "/owner/notice", title: "社区公告", icon: "Bell" },
    { path: "/owner/outage", title: "停水停电", icon: "Warning" },
    { path: "/owner/resident", title: "住户档案", icon: "User" },
    { path: "/owner/assistant", title: "智能问答", icon: "ChatDotRound" },
  ],
  1: [
    { path: "/worker/home", title: "首页", icon: "HomeFilled" },
    {
      title: "任务中心",
      icon: "Tools",
      children: [
        { path: "/worker/order/todo", title: "待办任务" },
        { path: "/worker/order/history", title: "历史记录" },
      ],
    },
    { path: "/worker/order/work-status", title: "我的资质", icon: "Medal" },
  ],
  2: [
    { path: "/property/dashboard", title: "数据大屏", icon: "DataAnalysis" },
    {
      title: "社区资源",
      icon: "OfficeBuilding",
      children: [
        { path: "/property/building", title: "楼栋管理" },
        { path: "/property/house", title: "房屋管理" },
        { path: "/property/resident", title: "住户档案" },
      ],
    },
    {
      title: "工单管理",
      icon: "Tools",
      children: [
        { path: "/property/repair", title: "工单监管" },
        { path: "/property/repair/type", title: "报修类型" },
        { path: "/property/repair/ai-report", title: "工单复盘" },
        { path: "/property/skill", title: "维修工资质" },
      ],
    },
    {
      title: "老人关怀",
      icon: "FirstAidKit",
      children: [
        { path: "/property/elder", title: "老人档案" },
        { path: "/property/elder-ai-monitor", title: "AI安全监测" },
        { path: "/property/elder-utility", title: "水电监测" },
        { path: "/property/elder/staff", title: "关怀人员" },
      ],
    },
    {
      title: "AI智能问答",
      icon: "ChatDotRound",
      children: [
        { path: "/property/ai/knowledge", title: "知识库管理" },
        { path: "/property/ai/knowledge-learn", title: "知识库自学习" },
        { path: "/property/ai/chat-active", title: "待处理对话" },
        { path: "/property/ai/chat-history", title: "历史对话" },
      ],
    },
    {
      title: "公告通知",
      icon: "Bell",
      children: [
        { path: "/property/notice/announce", title: "社区公告" },
        { path: "/property/notice/outage", title: "停水停电" },
      ],
    },
    {
      title: "用户管理",
      icon: "UserFilled",
      children: [
        { path: "/property/users/owner", title: "业主管理" },
        { path: "/property/users/worker", title: "维修工管理" },
        { path: "/property/users/property", title: "物业管理" },
      ],
    },
  ],
};

const defaultOpeneds = computed(() => {
  const type = userStore.userType;
  if (type === "1" && route.path.startsWith("/worker/order")) {
    return ["任务中心"];
  }
  if (type === "2") return [];
  return [];
});

const menus = computed(() => menuMap[userStore.userType] || []);

const avatarSrc = computed(() => {
  const av = userStore.user?.avatar;
  if (!av) return "";
  if (av.startsWith("http") || av.startsWith("data:")) return av;
  return "/api" + av;
});

const avatarText = computed(() => {
  const name = userStore.nickName || userStore.user?.username || "U";
  return name.charAt(0).toUpperCase();
});

const avatarFallbackStyle = computed(() => {
  if (avatarSrc.value) return {};
  return {
    backgroundColor: getRoleAvatarColor(userStore.userType),
    color: "#fff",
    fontWeight: 600,
  };
});

function handleCommand(cmd) {
  if (cmd === "profile") {
    const path = profilePathMap[userStore.userType];
    if (path) router.push(path);
  } else if (cmd === "logout") {
    confirmLogout();
  }
}

function confirmLogout() {
  ElMessageBox.confirm("确定退出系统吗？", "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(() => {
      userStore.logout();
      router.push("/login");
    })
    .catch(() => {});
}

onMounted(() => {
  if (userStore.token && !userStore.user?.userId) {
    userStore.fetchInfo().catch(() => {});
  }
});
</script>

<style scoped lang="scss">
.layout-container {
  height: 100vh;
}
.aside {
  background: linear-gradient(
    180deg,
    var(--brand-sidebar-bg) 0%,
    var(--brand-sidebar-bg-end) 100%
  );
  border-right: 1px solid var(--brand-border);
  transition: width 0.28s ease;
  overflow: hidden;
}
.logo {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 12px;
  border-bottom: 1px solid var(--brand-border);
  overflow: hidden;
}
.menu-scroll {
  height: calc(100vh - 56px);
  :deep(.el-menu),
  :deep(.el-menu--inline) {
    border-right: none;
    padding: 6px 0;
    background-color: transparent !important;
  }
  :deep(.el-sub-menu .el-menu) {
    background-color: transparent !important;
  }
  :deep(.el-menu-item) {
    height: 44px;
    line-height: 44px;
    margin: 2px 8px;
    border-radius: 6px;
    &.is-active {
      background: var(--brand-surface) !important;
      color: var(--brand-sidebar-text-active) !important;
      font-weight: 600;
      box-shadow: 0 1px 4px rgba(74, 108, 140, 0.08);
    }
    &:hover:not(.is-active) {
      background: rgba(255, 255, 255, 0.55) !important;
      color: var(--brand-sidebar-text-active) !important;
    }
  }
  :deep(.el-sub-menu__title) {
    height: 44px;
    line-height: 44px;
    margin: 2px 8px;
    border-radius: 6px;
    &:hover {
      background: rgba(255, 255, 255, 0.55) !important;
      color: var(--brand-sidebar-text-active) !important;
    }
  }
  :deep(.el-sub-menu.is-active > .el-sub-menu__title) {
    color: var(--brand-sidebar-text-active) !important;
    font-weight: 600;
  }
  :deep(.el-sub-menu .el-menu-item.is-active) {
    background: var(--brand-surface) !important;
    box-shadow: 0 1px 4px rgba(74, 108, 140, 0.08);
  }
  :deep(.el-sub-menu .el-menu-item) {
    padding-left: 52px !important;
    min-width: auto;
  }
}
.main-wrap {
  flex-direction: column;
  background: var(--brand-content-bg);
}
.navbar {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  background: var(--brand-content-bg);
  border-bottom: 1px solid var(--brand-content-border);
  z-index: 10;
}
.navbar-left {
  display: flex;
  align-items: center;
  gap: 14px;
}
.hamburger {
  font-size: 20px;
  cursor: pointer;
  color: #5a5e66;
  transition: color 0.2s;
  &:hover {
    color: var(--brand-primary);
  }
}
.navbar-right {
  display: flex;
  align-items: center;
  :deep(.el-dropdown) {
    line-height: normal;
  }
}
.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  outline: none;
  padding: 4px 8px;
  border-radius: 6px;
  transition: background 0.2s;
  &:hover {
    background: #f5f7fa;
  }
  .nick-name {
    font-size: 14px;
    color: var(--brand-text);
    max-width: 120px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    font-weight: 500;
  }
  .arrow {
    color: #909399;
    font-size: 12px;
  }
}
.app-main {
  padding: 0;
  overflow: auto;
  overflow-x: hidden;
  background: var(--brand-content-bg);

  &--full {
    overflow: hidden;
    height: calc(100vh - 56px);
    min-height: 0;
  }
}
</style>
