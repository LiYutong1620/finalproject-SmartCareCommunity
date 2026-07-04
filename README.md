# 智护社区：AI 智能服务平台

基于《需求规格说明书（SSR 简略版）》的前后端分离智慧社区项目，参考若依（RuoYi）的页面与 CRUD 写法。

**当前版本已实现：** 报修工单、公告通知、住户资源、老人关怀、系统管理，以及 **AI 智能问答（RAG + 人工客服）、知识库管理与自学习、报修语音输入** 等能力。

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
| 项目名称 | 智护社区：AI 智能服务平台 | 简称「智护社区」 |
| Java 根包 | `com.smartcare` | 后端统一包名 |
| 数据库 | `smart_care_community` | MySQL 库名 |
| 配置前缀 | `smartcare.*` | `application.yml` 自定义项 |
| AI 配置 | `ai.zhipu.*` | 智谱 GLM（密钥见下方说明） |

### 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | Spring Boot 3.2、Spring Security、JWT、MyBatis-Plus、MySQL 8、Knife4j、OkHttp、Apache POI、PDFBox |
| 前端 | Vue 3、Vite、Pinia、Vue Router、Element Plus、Axios |
| AI | 智谱 GLM-4-Plus（RAG 问答）、GLM-4V（图片识别）、GLM-4-Flash（知识抽取） |
| 数据库 | MySQL 8.0+ |

### 角色与演示账号

| 账号 | 密码 | 角色 | 说明 |
|------|------|------|------|
| property01 | admin123 | 物业 | 昵称「王管家」；资源、公告、工单、AI 管理 |
| owner01 | admin123 | 业主 | 报修、公告、智能问答 |
| worker01 | admin123 | 维修工 | 水电电路，工单作业 |
| worker02 | admin123 | 维修工 | 管道疏通（忙） |
| worker03 | admin123 | 维修工 | 家电维修 |
| worker04 | admin123 | 维修工 | 弱电/监控 |
| worker05 | admin123 | 维修工 | 综合维修（离线） |

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

> 脚本开头会 **预删除全部表** 再重建，**会清空该库已有数据**，请在导入前确认。

数据库账号密码需与后端配置一致，见下方「本地配置」。

### 2. 本地配置（数据库密码 / AI Key）

复制 `backend/src/main/resources/application-local.yml.example` 为同目录下的 **`application-local.yml`**（已被 `.gitignore` 忽略）：

```yaml
spring:
  datasource:
    username: root
    password: 你的MySQL密码   # 与 Navicat 连接时使用的密码一致

ai:
  zhipu:
    api-key: 你的智谱API密钥
```

也可设置环境变量 `MYSQL_USER`、`MYSQL_PASSWORD` 覆盖默认值（默认 `root` / `123456`）。

未配置智谱 API Key 时，AI 问答将使用本地知识库兜底，知识库自学习无法调用大模型。

### 3. 后端

```bash
cd backend
mvn spring-boot:run
```

- API：http://localhost:8080
- 接口文档：http://localhost:8080/doc.html

### 4. 前端

```bash
cd front
npm install
npm run dev
```

- 访问：http://localhost:5173（Vite 代理 `/api` → 后端 8080）

> 请使用 `npm run dev` 启动前端，不要直接打开 `dist/index.html`，否则 `/api` 请求会 404。

---

## 三、数据库说明

### 3.1 脚本文件

| 文件 | 作用 |
|------|------|
| `sql/smart_care_community.sql` | **唯一主库脚本**：基于现网导出清理后生成，含全部业务数据，可直接整库导入 |
| `sql/build_clean_sql.py` | 从 Navicat 导出文件重新生成主脚本（用法：`python build_clean_sql.py <导出文件路径>`） |
| `sql/upgrade_after_merge.sql` | **增量升级脚本**：已有旧库时补全字段与新表 |

> 合并分工3模块后若登录报「系统异常」或接口 500，通常是库结构未更新。请整库重导主脚本，或执行增量升级脚本。

### 3.2 表分组（主要）

| 前缀 | 说明 | 主要表 |
|------|------|--------|
| `cm_*` | 物业资源 | 楼栋、房屋、住户、标签等 |
| `cs_*` | 社区公告 | `cs_notice`、`cs_notice_read` |
| `rp_*` | 报修工单 | 工单、进度、类型、物料等 |
| `el_*` | 老人关怀 | 预警、水电监测、关怀工单、处置记录等 |
| `ai_*` / `kb_*` | AI 智能问答 | `ai_chat_session`、`ai_chat_message`、`kb_article`、`kb_learn_draft`、`cs_service_ticket` |
| `sys_*` | 系统 | 用户、消息、配置、登录日志等 |

### 3.3 已移除模块（脚本中不再包含）

- 社区活动、访客预约、邻里话题、亲情账号、业主投票、场地预约、投诉建议
- 财务缴费（账单、缴费流水等）
- 家政服务（`cs_housekeeping*`）、二手闲置（`cs_secondhand`）、健康档案（`el_health_*`）、旧统一用户表（`sys_user`）

---

## 四、功能模块（三端菜单）

| 模块 | 业主端 | 维修工端 | 物业端 |
|------|:------:|:--------:|:------:|
| 登录 / 个人中心 / 消息 | ✓ | ✓ | ✓ |
| 报修工单（含语音输入） | ✓ | ✓ | ✓ |
| 社区公告 / 停水停电 | ✓ | — | ✓ |
| 住户档案 | ✓ | — | ✓ |
| **智能问答**（文字/语音/图片、转人工） | ✓ | — | — |
| **AI 智能问答管理**（知识库、自学习、对话监管） | — | — | ✓ |
| 老人关怀 | — | — | ✓ |
| 数据大屏 | — | — | ✓ |
| 系统管理 | — | — | ✓ |

### 业主端菜单

报修工单 · 社区公告 · 停水停电 · 住户档案 · **智能问答** · 个人中心

### 物业端 · AI 智能问答管理

- **知识库管理**：条目 CRUD，标题/关键词/正文组合查询
- **知识库自学习**：从公告、咨询记录抽取知识点（去重），支持 Word/PDF/TXT 批量导入，物业审核后入库
- **待处理对话**：人工进行中会话，物业可回复
- **历史对话**：AI 纯问答 + 人工已结束会话，便于核对 AI 回答质量

### 演示：AI 与对话

| 场景 | 操作 |
|------|------|
| 转人工 | 业主端智能问答输入「转人工」或含「投诉」等关键词 |
| 待处理对话 | 物业端查看「投诉楼道杂物堆放」（owner02） |
| 历史对话 | 含 AI 问答记录与已结束人工对话 |

---

## 五、后端结构

```
com.smartcare
├── common/                 # AjaxResult、分页、全局异常
├── framework/              # Security、JWT、验证码、MyBatis-Plus、智谱 AI 客户端
├── system/                 # 登录、用户、消息、配置、个人中心
└── business/
    ├── ai/                 # RAG 问答、知识库、自学习、人工客服
    ├── community/          # 公告
    ├── property/           # 楼栋房屋住户等资源
    ├── repair/             # 报修工单三端
    ├── elder/              # 老人预警
    └── dashboard/          # 物业数据大屏
```

### 主要 API 前缀

| 前缀 | 作用 |
|------|------|
| `/owner/ai/*` | 业主智能问答 |
| `/property/ai/*` | 物业知识库、自学习、人工对话 |
| `/owner/repair` | 业主报修 |
| `/property/content/notice` | 物业公告 |
| `/property/*` | 社区资源、工单监管等 |

---

## 六、前端结构

```
front/src/
├── api/                    # owner、propertyAi、repair、property 等
├── composables/            # useAutoQuery、useSpeechInput 等
├── router/index.js
├── layout/index.vue
└── views/
    ├── owner/              # repair、assistant（智能问答）、notice …
    ├── property/ai/        # knowledge、knowledge-learn、chat-session-list、chat
    └── property/           # dashboard、repair、elder、notice …
```

---

## 七、其他说明

- **角色区分**：三端账号分表（`sys_owner_account` / `sys_worker_account` / `sys_property_account`）
- **无 Redis**：验证码存内存；认证为 JWT 无状态。
- **文件上传**：头像等保存在 `backend/upload/`；知识库文档导入支持 `.docx` / `.pdf` / `.txt`。
- **敏感配置**：`application-local.yml`、`.env`、本地上传目录已在 `.gitignore` 中忽略，**请勿将 API Key 提交到 Git**。
- **语音识别**：报修与智能问答使用浏览器 Web Speech API，推荐 Chrome / Edge。

---

## 八、后续可扩展

1. 维修工物料领用、工时打卡
2. 向量检索增强 RAG（当前为关键词检索 + 大模型生成）
3. 细粒度 RBAC 菜单权限
4. 报修工单图片上传（`rp_order_image` 表已预留）
