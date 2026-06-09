# Smart Care Community（智慧社区）

基于《需求规格说明书（SSR 简略版）》搭建的 Smart Care Community 前后端分离项目，参考若依（RuoYi）的页面与 CRUD 写法。**已实现除第五模块「全平台 AI 智能赋能」外的各业务模块。**

---

## 一、项目总览

```
finalproject/
├── sql/                    # 数据库脚本与增量补丁
├── backend/                # Spring Boot 3 后端（Java 17）
├── front/                  # Vue 3 前端
├── .gitignore              # Git 忽略规则
└── README.md               # 本说明文档
```

| 类型 | 名称 | 说明 |
|------|------|------|
| 项目名称 | Smart Care Community | 智慧社区平台 |
| Java 根包 | `com.smartcare` | 后端统一包名 |
| 数据库 | `smart_care_community` | MySQL 库名 |
| 配置前缀 | `smartcare.*` | `application.yml` 自定义项 |
| SSR | 需求规格说明书缩写 | 非项目技术缩写 |

### 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | Spring Boot 3.2、Spring Security、JWT、MyBatis-Plus、MySQL 8、Knife4j |
| 前端 | Vue 3、Vite、Pinia、Vue Router、Element Plus、Axios |
| 数据库 | MySQL 8.0 |

### 角色与演示账号

| 账号 | 密码 | 角色 | 说明 |
|------|------|------|------|
| property01 | admin123 | 物业 | 后台管理、内容审核、资源管理 |
| owner01 | admin123 | 业主 | 报修、社区服务、缴费等 |
| worker01 | admin123 | 维修工 | 工单作业 |

---

## 二、快速启动

### 1. 数据库

```bash
mysql -u root -p < sql/smart_care_community.sql
```

若项目已建库，按需执行增量补丁（顺序执行，列已存在可跳过对应语句）：

- `sql/patch_community_module.sql` — 业主社区服务字段与演示数据
- `sql/patch_community_fix_columns.sql` — 社区表缺列修复
- `sql/patch_property_module.sql` — 物业资源管理字段与车位缴费表
- `sql/patch_property_content.sql` — 投诉处理记录表

修改 `backend/src/main/resources/application.yml` 中的数据库账号密码。

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

## 三、`sql/` 目录说明

| 文件 | 作用 |
|------|------|
| `smart_care_community.sql` | **主库脚本**：建库、全业务表结构、字段注释、初始演示数据 |
| `patch_community_module.sql` | 社区业主端：报名凭证、帖子图片、投票选项、访客状态等 + 演示数据 |
| `patch_community_fix_columns.sql` | 修复社区相关表缺失列（若主库未含新字段） |
| `patch_property_module.sql` | 物业资源：房屋租赁字段、车位缴费表、住户标签、演示车位 |
| `patch_property_content.sql` | 物业内容：投诉处理日志表 `cs_complaint_log` |

---

## 四、后端 `backend/` 说明

### 4.1 根目录文件

| 文件 | 作用 |
|------|------|
| `pom.xml` | Maven 依赖与构建配置（Spring Boot、MyBatis-Plus、JWT、Knife4j 等） |
| `src/main/resources/application.yml` | 端口、数据源、JWT、文件上传路径、MyBatis-Plus 等配置 |

### 4.2 包结构总览

```
com.smartcare
├── SmartCareApplication.java      # 启动类
├── common/                        # 通用基础（响应体、异常、分页）
├── framework/                     # 框架层（安全、配置、验证码）
├── system/                        # 系统模块（用户、登录、消息、配置）
└── business/                      # 业务模块
    ├── community/                 # 社区内容与个人服务
    ├── property/                  # 住户与社区资源
    ├── repair/                    # 报修工单
    ├── finance/                   # 财务账单
    ├── elder/                     # 老人关怀
    └── dashboard/                 # 数据大屏统计
```

---

### 4.3 `com.smartcare` 根

| 文件 | 作用 |
|------|------|
| `SmartCareApplication.java` | Spring Boot 应用入口，`@SpringBootApplication` 启动扫描 |

---

### 4.4 `com.smartcare.common` — 通用层

**包职责**：统一 API 返回格式、分页封装、全局异常。

| 文件 | 作用 |
|------|------|
| `common/core/domain/AjaxResult.java` | 统一 JSON 响应 `{ code, msg, data }` |
| `common/core/domain/BaseEntity.java` | 实体基类：`createTime`、`updateTime` 自动填充 |
| `common/core/page/TableDataInfo.java` | 分页列表封装 `{ total, rows }` |
| `common/exception/ServiceException.java` | 业务异常，携带提示信息 |
| `common/exception/GlobalExceptionHandler.java` | 全局异常捕获，返回友好错误 |

---

### 4.5 `com.smartcare.framework` — 框架层

**包职责**：安全认证、系统配置、验证码、静态资源。

#### `framework/config`

| 文件 | 作用 |
|------|------|
| `SecurityConfig.java` | Spring Security：JWT 无状态、放行登录/验证码/静态上传 |
| `PasswordEncoderConfig.java` | BCrypt 密码编码器（独立配置，避免循环依赖） |
| `MybatisPlusConfig.java` | MyBatis-Plus 分页插件、字段自动填充 |
| `WebMvcConfig.java` | 静态资源映射 `/upload/**` → 本地上传目录 |

#### `framework/security`

| 文件 | 作用 |
|------|------|
| `JwtUtils.java` | JWT 生成与解析 |
| `JwtAuthenticationFilter.java` | 请求头 Token 校验过滤器 |
| `LoginUser.java` | 当前登录用户 Security 主体 |
| `SecurityUtils.java` | 获取当前 `userId`、用户信息工具类 |

#### `framework/captcha`

| 文件 | 作用 |
|------|------|
| `CaptchaService.java` | 图形验证码生成与校验（内存存储） |
| `CaptchaController.java` | `GET /captchaImage` 获取验证码 |

---

### 4.6 `com.smartcare.system` — 系统模块

**包职责**：账号认证、用户管理、消息中心、系统配置、登录日志、个人中心。

#### `system/domain` — 实体

| 文件 | 作用 |
|------|------|
| `SysUser.java` | 系统用户（业主/维修工/物业），含 `userType`、`houseId` |
| `SysConfig.java` | 系统参数键值 |
| `SysLoginLog.java` | 登录日志 |
| `SysMessage.java` | 消息主体 |
| `SysMessageUser.java` | 消息与用户关联（已读、阅读时间） |
| `dto/RegisterBody.java` | 注册请求 DTO |

#### `system/mapper` — 数据访问

| 文件 | 作用 |
|------|------|
| `SysUserMapper.java` | 用户表 `sys_user` |
| `SysConfigMapper.java` | 配置表 `sys_config` |
| `SysLoginLogMapper.java` | 登录日志表 `sys_login_log` |
| `SysMessageMapper.java` | 消息表 `sys_message` |
| `SysMessageUserMapper.java` | 消息用户关联表 `sys_message_user` |

#### `system/service` — 业务逻辑

| 文件 | 作用 |
|------|------|
| `SysUserService.java` | 用户 CRUD、改密、个人资料更新 |
| `SysLoginLogService.java` | 记录与查询登录日志 |
| `SysMessageService.java` | 发消息、已读、撤回、优先级 |

#### `system/controller` — 接口

| 文件 | 作用 |
|------|------|
| `AuthController.java` | `/login`、`/register`、`/getInfo` 认证 |
| `ProfileController.java` | `/system/user/profile` 个人中心（资料、头像、改密） |
| `SysUserController.java` | 物业端用户列表、重置密码 |
| `SysConfigController.java` | 系统参数增删改查 |
| `SysLoginLogController.java` | 登录日志查询 |
| `SysMessageController.java` | 消息中心列表、已读、发送 |

---

### 4.7 `com.smartcare.business.community` — 社区模块

**包职责**：公告、活动、论坛、投诉、访客、投票、场地、亲情绑定等社区服务。

#### `community/domain` — 实体（对应 `cs_*` 表）

| 文件 | 作用 |
|------|------|
| `CsNotice.java` | 社区公告 / 停水停电通知 |
| `CsNoticeRead.java` | 公告已读记录 |
| `CsActivity.java` | 社区活动 |
| `CsActivityReg.java` | 活动报名 |
| `CsComplaint.java` | 投诉建议 |
| `CsComplaintLog.java` | 投诉处理过程日志 |
| `CsForumPost.java` | 邻里论坛帖子 |
| `CsForumComment.java` | 帖子留言 |
| `CsFamilyBind.java` | 亲情账号绑定 |
| `CsVisitor.java` | 访客预约 |
| `CsVenue.java` | 公共场地 |
| `CsVenueBooking.java` | 场地预约 |
| `CsVote.java` | 业主投票议题 |
| `CsVoteRecord.java` | 投票记录（`voteOption` 映射列 `option`） |

#### `community/mapper` — 数据访问

与上述实体一一对应，另含 `CsNoticeReadMapper`（含 `markRead`、已读用户查询自定义 SQL）。

#### `community/service` — 业务逻辑

| 文件 | 作用 |
|------|------|
| `OwnerCommunityService.java` | **业主端**社区服务全集：公告已读、活动报名、论坛、车位、投票、账单、投诉列表等 |
| `PropertyCommunityService.java` | **物业端**内容管理：公告/活动发布下架、投诉受理回复、论坛审核、报名导出、阅读统计 |

#### `community/controller` — 接口

| 文件 | 作用 |
|------|------|
| `CsNoticeController.java` | 业主/物业公告列表；物业发布、编辑、下架（部分路径） |
| `CsComplaintController.java` | 业主提交投诉、业主投诉列表 |
| `OwnerCommunityController.java` | 业主端 `/owner/*` 社区 API（活动、论坛、访客、投票等） |
| `OwnerFileController.java` | 业主端图片上传 `/owner/file/upload` |
| `PropertyCommunityController.java` | 物业端 `/property/content/*` 内容与投诉管理 |

---

### 4.8 `com.smartcare.business.property` — 物业资源模块

**包职责**：楼栋、房屋、设备、住户档案、车位、租赁、入住迁出、违规住户。

#### `property/domain` — 实体（对应 `cm_*` 表）

| 文件 | 作用 |
|------|------|
| `CmBuilding.java` | 楼栋 |
| `CmHouse.java` | 房屋（含租赁、租客信息） |
| `CmEquipment.java` | 公共设备（电梯/门禁/路灯） |
| `CmResident.java` | 住户档案 |
| `CmResidentTag.java` | 住户标签定义 |
| `CmParking.java` | 车位资源 |
| `CmParkingBind.java` | 车位与住户绑定 |
| `CmParkingPayment.java` | 车位缴费记录 |
| `CmViolation.java` | 违规住户 / 黑名单 |
| `CmMoveApply.java` | 入住 / 迁出申请 |

#### `property/mapper` — 数据访问

与上述实体对应；`CmResidentTagRelMapper` 为住户-标签多对多关联 SQL。

#### `property/service`

| 文件 | 作用 |
|------|------|
| `PropertyResourceService.java` | 物业资源管理业务：楼栋房屋、住户搜索、车位、违规、入住迁出审核等 |

#### `property/controller`

| 文件 | 作用 |
|------|------|
| `PropertyResourceController.java` | `/property/*` 资源管理 REST API |

---

### 4.9 `com.smartcare.business.repair` — 报修模块

**包职责**：业主报修、维修工作业、物业派单监管。

| 层级 | 文件 | 作用 |
|------|------|------|
| domain | `RpOrder.java` | 报修工单 |
| domain | `RpOrderProgress.java` | 工单进度节点 |
| mapper | `RpOrderMapper.java` | 工单表 `rp_order` |
| mapper | `RpOrderProgressMapper.java` | 进度表 `rp_order_progress` |
| service | `RpOrderService.java` | 工单创建、派单、状态流转、催单、复制 |
| controller | `OwnerRepairController.java` | 业主 `/owner/repair/*` |
| controller | `WorkerRepairController.java` | 维修工 `/worker/repair/*` |
| controller | `PropertyRepairController.java` | 物业 `/property/repair/*` |

---

### 4.10 `com.smartcare.business.finance` — 财务模块

| 文件 | 作用 |
|------|------|
| `domain/FnBill.java` | 费用账单 |
| `domain/FnFeeItem.java` | 收费项目（物业费/水电费等） |
| `domain/FnPayment.java` | 缴费流水 |
| `mapper/FnBillMapper.java` | 账单数据访问 |
| `mapper/FnFeeItemMapper.java` | 收费项数据访问 |
| `mapper/FnPaymentMapper.java` | 缴费记录数据访问 |
| `controller/FinanceController.java` | 业主账单查询、物业出账 |

---

### 4.11 `com.smartcare.business.elder` — 老人关怀

| 文件 | 作用 |
|------|------|
| `domain/ElAlert.java` | 老人居家异常预警 |
| `mapper/ElAlertMapper.java` | 预警数据访问 |
| `controller/ElderCareController.java` | 物业端预警列表与处置 |

---

### 4.12 `com.smartcare.business.dashboard` — 数据大屏

| 文件 | 作用 |
|------|------|
| `controller/DashboardController.java` | 物业端 `/property/dashboard/stats` 统计概览 |

---

## 五、前端 `front/` 说明

### 5.1 根目录文件

| 文件 | 作用 |
|------|------|
| `package.json` | 依赖与 npm 脚本（`dev` / `build`） |
| `vite.config.js` | Vite 配置：别名 `@`、开发端口 80、`/api` 代理 |
| `index.html` | SPA 入口 HTML |

### 5.2 `src/` 目录总览

```
src/
├── main.js           # 应用入口：Vue、Pinia、Router、Element Plus
├── App.vue           # 根组件，仅 <router-view />
├── api/              # 后端接口封装
├── router/           # 路由（业主/维修工/物业三端）
├── store/            # Pinia 状态
├── utils/            # 工具（Token、Axios）
├── styles/           # 全局样式
├── layout/           # 三端共用布局（侧栏 + 顶栏）
└── views/            # 页面视图
```

---

### 5.3 `src/api/` — 接口层

| 文件 | 作用 |
|------|------|
| `login.js` | 登录、注册、验证码、获取用户信息 |
| `profile.js` | 个人中心（资料、头像、改密） |
| `repair.js` | 报修工单（业主/维修工/物业） |
| `community.js` | 公告、投诉（旧路径兼容） |
| `owner.js` | 业主社区服务全套 API |
| `property.js` | 物业资源管理 API |
| `propertyContent.js` | 物业内容与投诉管理 API |
| `system.js` | 系统用户、配置、登录日志 |

---

### 5.4 `src/utils/` — 工具

| 文件 | 作用 |
|------|------|
| `auth.js` | Token 与用户信息 localStorage 读写 |
| `request.js` | Axios 实例：自动带 JWT、统一错误处理 |

---

### 5.5 `src/store/` — 状态

| 文件 | 作用 |
|------|------|
| `user.js` | 当前用户、Token、`fetchInfo`、`logout` |

---

### 5.6 `src/router/` — 路由

| 文件 | 作用 |
|------|------|
| `index.js` | 路由表：`/login`、`/owner/*`、`/worker/*`、`/property/*`；登录守卫 |

---

### 5.7 `src/layout/` — 布局

| 文件 | 作用 |
|------|------|
| `index.vue` | 三端共用：左侧菜单、顶栏（头像下拉、个人中心、退出确认）、`<router-view>` |

---

### 5.8 `src/views/` — 页面

#### 公共

| 文件 | 作用 |
|------|------|
| `login/index.vue` | 登录 / 注册（双 Tab + 验证码） |
| `profile/index.vue` | 个人中心（资料、头像、改密）三端共用 |
| `dashboard/index.vue` | 通用首页占位 |

#### 业主端 `views/owner/`

| 文件 | 作用 |
|------|------|
| `repair/index.vue` | 报修工单 |
| `notice/index.vue` | 社区公告（已读/未读） |
| `outage/index.vue` | 停水停电通知 |
| `activity/index.vue` | 社区活动报名 |
| `forum/index.vue` | 邻里话题发帖留言 |
| `visitor/index.vue` | 访客预约与通行码 |
| `family/index.vue` | 亲情账号与预警授权 |
| `venue/index.vue` | 场地预约 |
| `vote/index.vue` | 业主投票 |
| `resident/index.vue` | 住户档案查看 |
| `complaint/index.vue` | 投诉建议 |
| `bill/index.vue` | 缴费账单与缴费记录 |

#### 维修工端 `views/worker/`

| 文件 | 作用 |
|------|------|
| `order/index.vue` | 工单接单与作业 |

#### 物业端 `views/property/`

| 文件 | 作用 |
|------|------|
| `dashboard/index.vue` | 数据大屏 |
| `resident/index.vue` | 社区资源管理（楼栋、房屋、设备、住户、车位、租赁、入住迁出、违规） |
| `repair/index.vue` | 工单监管与派单 |
| `elder/index.vue` | 老人关怀预警处置 |
| `notice/index.vue` | 公告 / 停水停电发布与阅读统计 |
| `activity/index.vue` | 活动发布、报名名单、导出 |
| `complaint/index.vue` | 投诉受理、回复、统计 |
| `forum/index.vue` | 论坛帖子 / 留言审核 |
| `bill/index.vue` | 财务台账 |

#### 系统管理 `views/system/`（物业端菜单）

| 文件 | 作用 |
|------|------|
| `user/index.vue` | 用户管理 |
| `config/index.vue` | 系统参数配置 |
| `loginlog/index.vue` | 登录日志 |
| `message/index.vue` | 消息中心（三端共用页面） |

---

### 5.9 `src/styles/`

| 文件 | 作用 |
|------|------|
| `index.scss` | 全局重置、登录页样式 |

---

## 六、功能模块对照（已实现）

| 模块 | 业主端 | 维修工端 | 物业端 |
|------|--------|----------|--------|
| 系统基础 | 消息、个人中心 | 消息、个人中心 | 用户、配置、日志、消息 |
| 报修工单 | ✓ | ✓ | ✓ |
| 社区与个人服务 | ✓ | — | — |
| 住户与资源管理 | 档案查看 | — | ✓ |
| 社区内容与投诉 | 查看/参与 | — | ✓ |
| 财务账单 | 查询缴费 | — | 出账台账 |
| 老人关怀 | 授权预警 | — | 预警处置 |
| 数据大屏 | — | — | ✓ |
| AI 智能赋能 | — | — | **未实现** |

---

## 七、其他说明

- **若依参考范围**：仅 UI 与 CRUD 写法；已删除若依 RBAC 冗余表（`sys_role`、`sys_menu` 等），角色由 `sys_user.user_type` 区分（0 业主 / 1 维修工 / 2 物业）。
- **无 Redis**：验证码、会话均使用内存或 JWT 无状态方案。
- **文件上传**：头像与社区图片保存在 `backend/upload/`，通过 `/upload/**` 访问。
- **`.gitignore`**：忽略 `node_modules`、`target`、上传目录、IDE 配置等。

---

## 八、后续可扩展

1. 维修工物料领用、工时打卡、知识库
2. 物业设备维保计划、电子发票
3. 细粒度 RBAC 菜单权限
4. 第五模块 AI：语音、RAG、智能派单（独立服务对接）
