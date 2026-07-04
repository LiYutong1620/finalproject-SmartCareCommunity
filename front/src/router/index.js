import { createRouter, createWebHistory } from "vue-router";
import { getToken, getRoleHome, getUser } from "@/utils/auth";

const constantRoutes = [
  {
    path: "/login",
    component: () => import("@/views/login/index.vue"),
    meta: { title: "登录" },
  },
  {
    path: "/register",
    component: () => import("@/views/register/index.vue"),
    meta: { title: "注册" },
  },
  {
    path: "/forgot-password",
    component: () => import("@/views/forgot-password/index.vue"),
    meta: { title: "重置密码" },
  },
  {
    path: "/",
    redirect: () => (getToken() ? getRoleHome() : "/login"),
  },
];

const ownerRoutes = {
  path: "/owner",
  component: () => import("@/layout/index.vue"),
  meta: { title: "业主端", roles: ["0"] },
  children: [
    {
      path: "repair",
      component: () => import("@/views/owner/repair/index.vue"),
      meta: { title: "报修工单" },
    },
    {
      path: "repair/detail/:orderId",
      component: () => import("@/views/owner/repair/detail.vue"),
      meta: { title: "工单详情" },
    },
    {
      path: "repair/accept/:orderId",
      component: () => import("@/views/owner/repair/accept.vue"),
      meta: { title: "工单验收" },
    },
    {
      path: "notice",
      component: () => import("@/views/owner/notice/index.vue"),
      meta: { title: "社区公告" },
    },
    {
      path: "notice/detail/:id",
      component: () => import("@/views/owner/notice/detail.vue"),
      meta: { title: "公告详情" },
    },
    {
      path: "outage",
      component: () => import("@/views/owner/outage/index.vue"),
      meta: { title: "停水停电" },
    },
    {
      path: "outage/detail/:id",
      component: () => import("@/views/owner/outage/detail.vue"),
      meta: { title: "通知详情" },
    },
    {
      path: "resident",
      component: () => import("@/views/owner/resident/index.vue"),
      meta: { title: "住户档案" },
    },
    {
      path: "assistant",
      component: () => import("@/views/owner/assistant/index.vue"),
      meta: { title: "智能问答" },
    },
    {
      path: "profile",
      component: () => import("@/views/profile/index.vue"),
      meta: { title: "个人中心" },
    },
  ],
};

const workerRoutes = {
  path: "/worker",
  component: () => import("@/layout/index.vue"),
  meta: { title: "维修工端", roles: ["1"] },
  redirect: "/worker/home",
  children: [
    {
      path: "home",
      component: () => import("@/views/worker/home/index.vue"),
      meta: { title: "首页" },
    },
    {
      path: "order",
      component: () => import("@/views/worker/order/TaskLayout.vue"),
      redirect: "/worker/order/todo",
      meta: { title: "任务中心" },
      children: [
        {
          path: "todo",
          component: () => import("@/views/worker/order/todo.vue"),
          meta: { title: "待办任务", parent: "任务中心" },
        },
        {
          path: "history",
          component: () => import("@/views/worker/order/history.vue"),
          meta: { title: "历史记录", parent: "任务中心" },
        },
      ],
    },
    {
      path: "order/detail/:orderId",
      component: () => import("@/views/worker/order/detail.vue"),
      meta: { title: "工单详情" },
    },
    {
      path: "order/work-status",
      component: () => import("@/views/worker/order/profile.vue"),
      meta: { title: "我的资质" },
    },
    {
      path: "profile",
      component: () => import("@/views/profile/index.vue"),
      meta: { title: "个人中心" },
    },
  ],
};

const propertyRoutes = {
  path: "/property",
  component: () => import("@/layout/index.vue"),
  meta: { title: "物业端", roles: ["2"] },
  children: [
    {
      path: "building",
      component: () => import("@/views/property/building/index.vue"),
      meta: { title: "楼栋管理", parent: "社区资源" },
    },
    {
      path: "house",
      component: () => import("@/views/property/house/index.vue"),
      meta: { title: "房屋管理", parent: "社区资源" },
    },
    {
      path: "resident",
      component: () => import("@/views/property/resident/index.vue"),
      meta: { title: "住户档案", parent: "社区资源" },
    },
    {
      path: "repair",
      component: () => import("@/views/property/repair/index.vue"),
      meta: { title: "工单监管", parent: "工单管理" },
    },
    {
      path: "repair/detail/:orderId",
      component: () => import("@/views/property/repair/detail.vue"),
      meta: { title: "工单详情", parent: "工单管理" },
    },
    {
      path: "repair/type",
      component: () => import("@/views/property/repair/type-manage.vue"),
      meta: { title: "报修类型", parent: "工单管理" },
    },
    {
      path: "repair/ai-report",
      component: () => import("@/views/property/repair/ai-report.vue"),
      meta: { title: "工单复盘", parent: "工单管理" },
    },
    {
      path: "elder",
      component: () => import("@/views/property/elder/index.vue"),
      meta: { title: "老人档案", parent: "老人关怀" },
    },
    {
      path: "elder-ai-monitor",
      name: "ElderAiMonitor",
      component: () => import("@/views/property/elder/ai-monitor.vue"),
      meta: { title: "AI安全监测", parent: "老人关怀", roles: ["2"] },
    },
    {
      path: "elder-utility",
      name: "ElderUtility",
      component: () => import("@/views/property/elder/utility.vue"),
      meta: { title: "水电监测", parent: "老人关怀", roles: ["2"] },
    },
    {
      path: "elder/staff",
      component: () => import("@/views/property/elder/staff.vue"),
      meta: { title: "关怀人员", parent: "老人关怀" },
    },
    {
      path: "notice/announce",
      component: () => import("@/views/property/notice/index.vue"),
      meta: { title: "社区公告", noticeType: "announce", parent: "公告通知" },
    },
    {
      path: "notice/outage",
      component: () => import("@/views/property/notice/index.vue"),
      meta: { title: "停水停电", noticeType: "outage", parent: "公告通知" },
    },
    { path: "notice", redirect: "/property/notice/announce" },
    { path: "ai", redirect: "/property/ai/knowledge" },
    {
      path: "ai/knowledge",
      component: () => import("@/views/property/ai/knowledge.vue"),
      meta: { title: "知识库管理", parent: "AI智能问答" },
    },
    {
      path: "ai/knowledge-learn",
      component: () => import("@/views/property/ai/knowledge-learn.vue"),
      meta: { title: "知识库自学习", parent: "AI智能问答" },
    },
    {
      path: "ai/chat-active",
      component: () => import("@/views/property/ai/chat-session-list.vue"),
      meta: { title: "待处理对话", mode: "active", parent: "AI智能问答" },
    },
    {
      path: "ai/chat-history",
      component: () => import("@/views/property/ai/chat-session-list.vue"),
      meta: { title: "历史对话", mode: "history", parent: "AI智能问答" },
    },
    { path: "ai/chat-list", redirect: "/property/ai/chat-active" },
    {
      path: "ai/chat/:sessionId",
      component: () => import("@/views/property/ai/chat.vue"),
      meta: { title: "对话详情", parent: "AI智能问答", fullHeight: true },
    },
    {
      path: "dashboard",
      component: () => import("@/views/property/dashboard/index.vue"),
      meta: { title: "数据大屏" },
    },
    {
      path: "users/owner",
      component: () => import("@/views/system/user/index.vue"),
      meta: { title: "业主管理", parent: "用户管理", userType: "0" },
    },
    {
      path: "users/worker",
      component: () => import("@/views/system/user/index.vue"),
      meta: { title: "维修工管理", parent: "用户管理", userType: "1" },
    },
    {
      path: "users/property",
      component: () => import("@/views/system/user/index.vue"),
      meta: { title: "物业管理", parent: "用户管理", userType: "2" },
    },
    { path: "user", redirect: "/property/users/owner" },
    {
      path: "skill",
      name: "WorkerSkill",
      component: () => import("@/views/system/skill/index.vue"),
      meta: { title: "维修工资质", parent: "工单管理", roles: ["2"] },
    },
    {
      path: "profile",
      component: () => import("@/views/profile/index.vue"),
      meta: { title: "个人中心" },
    },
  ],
};

const router = createRouter({
  history: createWebHistory(),
  routes: [...constantRoutes, ownerRoutes, workerRoutes, propertyRoutes],
});

/** 收集路由链上要求的角色（userType: 0业主 1维修工 2物业） */
function collectRequiredRoles(route) {
  const roles = new Set();
  route.matched.forEach((record) => {
    if (record.meta?.roles?.length) {
      record.meta.roles.forEach((r) => roles.add(r));
    }
  });
  return [...roles];
}

router.beforeEach((to, from, next) => {
  const token = getToken();
  const home = getRoleHome();

  // 已登录访问登录/注册/忘记密码 → 进入对应角色首页
  if (to.path === "/login" || to.path === "/register" || to.path === "/forgot-password") {
    return token ? next(home) : next();
  }

  // 未登录 → 登录页
  if (!token) {
    return next("/login");
  }

  // 已登录访问根路径或旧通用首页 → 角色首页
  if (to.path === "/" || to.path === "/dashboard") {
    return next(home);
  }

  // 按 meta.roles 限制跨端 URL 访问
  const requiredRoles = collectRequiredRoles(to);
  if (requiredRoles.length > 0) {
    const userType = getUser()?.userType;
    if (!userType || !requiredRoles.includes(userType)) {
      return next(home);
    }
  }

  next();
});

export default router;
