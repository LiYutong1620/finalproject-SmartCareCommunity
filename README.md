# Smart Care Community（智慧社区）

基于《需求规格说明书（SSR 简略版）》的前后端分离智慧社区项目，参考若依（RuoYi）的页面与 CRUD 写法。**当前版本已实现报修工单、公告通知、住户资源、老人关怀、系统管理等核心功能；未实现第五模块「全平台 AI 智能赋能」。**

---

## 一、项目总览

```
finalproject/
├── sql/                    # 数据库脚本（单文件完整导入）
├── backend/                # Spring Boot 3 后端（Java 17）
├── front/                  # Vue 3 前端
├── .gitignore
└── README.md
```

| 类型 | 名称 | 说明 |
|------|------|------|
| 项目名称 | Smart Care Community | 智慧社区平台 |
| Java 根包 | `com.smartcare` | 后端统一包名 |
| 数据库 | `smart_care_community` | MySQL 库名 |
| 配置前缀 | `smartcare.*` | `application.yml` 自定义项 |

### 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | Spring Boot 3.2、Spring Security、JWT、MyBatis-Plus、MySQL 8、Knife4j |
| 前端 | Vue 3、Vite、Pinia、Vue Router、Element Plus、Axios |
| 数据库 | MySQL 8.0+ |

### 角色与演示账号

| 账号 | 密码 | 角色 | 说明 |
|------|------|------|------|
| property01 | admin123 | 物业 | 资源管理、公告发布、工单监管 |
| owner01 | admin123 | 业主 | 报修、公告、住户档案 |
| worker01 | admin123 | 维修工 | 工单作业 |

---

## 二、快速启动

### 1. 数据库（完整重新导入）

**方式 A：命令行**

```bash
mysql -u root -p < sql/smart_care_community.sql
```

**方式 B：Navicat**

1. 连接 MySQL
2. 菜单 **运行 SQL 文件**，选择 `sql/smart_care_community.sql`
3. 执行（脚本会自动 `CREATE DATABASE`、建表并写入演示数据）

> 脚本会先 `DROP TABLE` 再重建，**会清空该库已有数据**，请在导入前确认。

修改 `backend/src/main/resources/application.yml` 中的数据库账号密码（默认 `root` / `123456`）。

### 2. 后端

```bash
cd backend
mvn spring-boot:run
```

- API：http://localhost:8080
- 接口文档：http://localhost:8080/doc.html

### 3. 前端

```bash
cd front
npm install
npm run dev
```

- 访问：http://localhost（Vite 代理 `/api` → 后端 8080）

---

## 三、数据库说明

### 3.1 脚本文件

| 文件 | 作用 |
|------|------|
| `sql/smart_care_community.sql` | **唯一主库脚本**：建库、48 张业务表、演示数据，可直接整库导入 |

### 3.2 表分组（48 张）

| 前缀 | 说明 | 主要表 |
|------|------|--------|
| `cm_*` | 物业资源 | 楼栋、房屋、设备、住户、标签、车位、绑定、入住迁出、违规 |
| `cs_*` | 社区公告 | `cs_notice`（公告/停水停电）、`cs_notice_read`（已读） |
| `rp_*` | 报修工单 | 工单、进度、类型、物料、工时、评价等 |
| `el_*` | 老人关怀 | 预警、健康档案、探访计划等（当前 UI 主要用 `el_alert`） |
| `sys_*` | 系统 | 用户、消息、配置、登录日志、字典等 |
| `kb_*` / `mt_*` | 扩展预留 | 知识库、维保计划（表结构预留，前端未全量接入） |

### 3.3 当前版本已移除（脚本中不再包含）

以下模块已从业务与数据库中剔除，重新导入后不会创建对应表：

- 社区活动、访客预约、邻里话题、亲情账号、业主投票、场地预约、投诉建议
- 财务缴费（账单、缴费流水、收费项、车位缴费记录）

---

## 四、功能模块（三端菜单）

| 模块 | 业主端 | 维修工端 | 物业端 |
|------|:------:|:--------:|:------:|
| 登录 / 个人中心 / 消息 | ✓ | ✓ | ✓ |
| 报修工单 | ✓ | ✓（作业） | ✓（监管） |
| 社区公告 / 停水停电 | ✓ | — | ✓（发布） |
| 住户档案 | ✓（查看） | — | ✓（资源管理） |
| 老人关怀 | — | — | ✓ |
| 数据大屏 | — | — | ✓ |
| 系统管理（用户/配置/日志） | — | — | ✓ |
| AI 智能赋能 | — | — | **未实现** |

### 业主端菜单

报修工单 · 社区公告 · 停水停电 · 住户档案 · 消息中心 · 个人中心

### 维修工端菜单

工单作业 · 消息中心 · 个人中心

### 物业端菜单

数据大屏 · 社区资源 · 工单监管 · 老人关怀 · 公告通知 · 系统配置 · 用户管理 · 登录日志 · 消息中心 · 个人中心

---

## 五、后端结构

```
com.smartcare
├── SmartCareApplication.java
├── common/                 # AjaxResult、分页、全局异常
├── framework/              # Security、JWT、验证码、MyBatis-Plus 配置
├── system/                 # 登录、用户、消息、配置、个人中心
└── business/
    ├── community/          # 公告（Owner / Property Content API）
    ├── property/           # 楼栋房屋住户车位等资源
    ├── repair/             # 报修工单三端
    ├── elder/              # 老人预警
    └── dashboard/          # 物业数据大屏统计
```

### 主要 Controller

| 文件 | 路径前缀 | 作用 |
|------|----------|------|
| `AuthController` | `/login` 等 | 登录、注册、用户信息 |
| `ProfileController` | `/system/user/profile` | 个人资料、头像、改密 |
| `OwnerRepairController` | `/owner/repair` | 业主报修 |
| `WorkerRepairController` | `/worker/repair` | 维修工作业 |
| `PropertyRepairController` | `/property/repair` | 物业派单监管 |
| `OwnerCommunityController` | `/owner/notice`、`/owner/resident` | 业主公告、住户档案 |
| `PropertyCommunityController` | `/property/content/notice` | 物业公告管理 |
| `PropertyResourceController` | `/property/*` | 社区资源 CRUD |
| `ElderCareController` | `/property/elder` | 老人预警处置 |
| `DashboardController` | `/property/dashboard` | 运营统计 |

---

## 六、前端结构

```
front/src/
├── api/                    # login、profile、repair、owner、property、propertyContent、system
├── router/index.js         # 三端路由与登录守卫
├── layout/index.vue        # 侧栏 + 顶栏布局
├── store/user.js           # 用户状态
├── utils/                  # auth、request（Axios + JWT）
└── views/
    ├── login/              # 登录注册
    ├── profile/            # 个人中心（三端共用）
    ├── owner/              # repair、notice、outage、resident
    ├── worker/             # order
    ├── property/           # dashboard、resident、repair、elder、notice
    └── system/             # user、config、loginlog、message
```

---

## 七、其他说明

- **角色区分**：由 `sys_user.user_type` 字段区分（0 业主 / 1 维修工 / 2 物业），前端按类型加载不同菜单。
- **无 Redis**：验证码存内存，认证使用 JWT 无状态方案。
- **文件上传**：头像等保存在 `backend/upload/`，通过 `/upload/**` 访问。
- **`.gitignore`**：已忽略 `node_modules`、`target`、本地上传目录等。

---

## 八、后续可扩展

1. 维修工物料领用、工时打卡、知识库（`kb_article` 表已预留）
2. 设备维保计划（`mt_plan` / `mt_record` 表已预留）
3. 细粒度 RBAC 菜单权限
4. 第五模块 AI：语音、RAG、智能派单
