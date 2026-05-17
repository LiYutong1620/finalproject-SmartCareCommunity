# Smart Care Community（智慧社区）

基于《需求规格说明书（SSR 简略版）》搭建的 Smart Care Community 前后端分离项目，参考若依（RuoYi）架构风格。**已实现除第五模块「全平台 AI 智能赋能」外的各业务模块框架与核心 API。**

## 项目结构

```
finalproject/
├── sql/init.sql              # MySQL 数据库脚本
├── backend/                  # Spring Boot 3 后端
└── front/                    # Vue 3 + Element Plus 前端
```

## 命名说明

| 类型 | 名称 | 说明 |
|------|------|------|
| 项目名称 | **Smart Care Community** | 智慧社区平台 |
| Java 包名 | `com.smartcare` | 与项目英文名对应 |
| 数据库 | `smart_care_community` | MySQL 库名 |
| 配置前缀 | `smartcare.*` | `application.yml` 自定义配置 |
| 需求文档 | SSR 简略版 | **SSR = 需求规格说明书**（Software Requirements Specification），非项目缩写 |

## 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | Spring Boot 3.2、Spring Security、JWT、MyBatis-Plus、MySQL 8、Knife4j |
| 前端 | Vue 3、Vite、Pinia、Vue Router、Element Plus、Axios |
| 数据库 | MySQL 8.0（库名 `smart_care_community`） |

## 功能模块（非 AI）

### 一、系统通用基础
- 统一消息中心（推送、已读、撤回、优先级）
- 账号登录/注册、登录日志
- 系统参数配置

### 二、业主端
- 报修工单（提交、撤销、催单、列表）
- 社区公告、投诉建议、缴费账单查询

### 三、维修工端
- 工单接单、状态更新、完成维修

### 四、物业端
- 住户/楼栋管理
- 工单监管与派单
- 老人关怀预警处置
- 公告/投诉管理
- 财务账单、数据大屏统计
- 系统配置、用户、登录日志

### 未实现（第五模块 AI）
- 语音交互、RAG 问答、智能派单、时序预警算法等 AI 能力预留扩展

## 快速启动

### 1. 数据库

```bash
mysql -u root -p < sql/init.sql
```

修改 `backend/src/main/resources/application.yml` 中的数据库连接信息。

> 说明：若依仅作前端页面与 CRUD 写法参考。`sql/init.sql` 保留全部业务表（含待开发功能），**仅删除若依 RBAC 冗余表**（`sys_role`、`sys_user_role`、`sys_menu`、`sys_role_menu`）；共约 **50 张表**，每张表及每个字段均有注释。当前未使用 Redis。

**执行方式**（会重建库内表，请先备份）：
```bash
mysql -u root -p < sql/init.sql
```

### 2. 后端

```bash
cd backend
mvn spring-boot:run
```

- API 地址: http://localhost:8080
- 接口文档: http://localhost:8080/doc.html

### 3. 前端

```bash
cd front
npm install
npm run dev
```

- 访问: http://localhost

## 演示账号

| 账号 | 密码 | 角色 |
|------|------|------|
| property01 | admin123 | 物业（含后台管理） |
| owner01 | admin123 | 业主 |
| worker01 | admin123 | 维修工 |

## 后续扩展建议

1. 补充活动报名、访客预约、论坛、投票、场地预约等业主端 CRUD 页面
2. 维修工物料领用、工时打卡、知识库检索
3. 物业设备维保、发票、权限菜单（RBAC）细粒度控制
4. 第五模块 AI：独立 AI 服务，通过 Feign/消息队列与各端集成
