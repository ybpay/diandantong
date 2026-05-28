# diandantong 迁移质量评估报告

评估日期：2026-05-28

## 一、技术栈对比

| 维度 | 原始系统 (Phase 0 前) | 当前系统 (dev 分支) | 迁移状态 |
|------|----------------------|-------------------|---------|
| **Ruby** | 2.1.6 | 4.0.5 | 已完成 |
| **Rails** | 4.1.13 | 8.1.0 | 已完成 |
| **数据库** | MySQL (mysql2 0.3.17) | PostgreSQL 18 (pg ~>1.5) | 已完成 |
| **多数据库** | ar-octopus 0.9.2 | 待清理 (10 文件仍引用 Octopus) | 部分完成 |
| **Web 服务器** | Unicorn | Puma | 已完成 |
| **资产管线** | Sprockets 2.11 | Propshaft | 已完成 |
| **后台任务** | Sidekiq 4.1 (47 Workers) | Sidekiq 8.0 (47 Workers) | 已完成 |
| **缓存/队列/Cable** | Redis 手动配置 | Solid Cache + Solid Queue + Solid Cable | 已完成 |
| **认证** | Devise 3.4 + CanCan | Devise 4.9 + devise-jwt | 已完成 |
| **授权** | CanCan (7 文件) | ActionPolicy (Gem 已引入，未在代码中使用) | 未落地 |
| **状态机** | workflow + state_machine | AASM (15 个模型) | 已完成 |
| **软删除** | Paranoia | Discard (1 个模型) | 极少落地 |
| **分页** | will_paginate / Kaminari | Pagy | 已完成 |
| **OAuth** | Doorkeeper 3.1 | Doorkeeper 5.7 | 已完成 |
| **前端-后台** | AngularJS 1.3 + HAML (730 个 HAML 文件) | Vue 3 + TypeScript + Vite (48 views) | 双轨并存 |
| **前端-微信** | AngularJS 1.3 + HAML | Vue 3 + Vant 4 (16 views) | 双轨并存 |
| **前端-收银** | AngularJS 1.3 + JS (6 个子应用) | Vue 3 + TypeScript + Vite (7 个子应用) | 双轨并存 |
| **前端-代理** | AngularJS 1.3 | Vue 3 (12 views) | 双轨并存 |
| **CSS** | Bootstrap 3 + SCSS | Tailwind CSS (已配置，114 个 Vue 文件使用) | 已完成 |
| **测试框架** | Minitest + FactoryGirl (216 测试文件) | RSpec + FactoryBot (7 spec 文件) | 严重不足 |
| **容器化** | 无 | Docker + Docker Compose | 已完成 |
| **部署** | Capistrano | Kamal 2 | 已完成 |
| **CI** | 无 | GitHub Actions (RuboCop + Test + Docker build) | 已完成 |
| **富文本** | CKEditor | 未迁移 | 未完成 |
| **文件上传** | CarrierWave | 未迁移到 ActiveStorage | 未完成 |
| **实时通信** | PrivatePub/Faye | ActionCable (WebPOS notify) | 部分完成 |

## 二、引擎级迁移质量

### 2.1 _core 引擎 — 核心层

| 指标 | 数值 | 评估 |
|------|------|------|
| 模型数 | 752 | 保留完整 |
| 控制器数 | 19 | 已拆分为 API v1 命名空间 |
| Sidekiq Workers | 47 | 全部保留 |
| AASM 状态机 | 15 个模型 | 已迁移 |
| Concerns | 18 | 保留 |
| Service Objects | 4 | 新增 |
| HAML/ERB 视图 | 5 | 仅残留布局文件 |
| alias_method_chain | 42 文件 | **未清理** |
| RSpec 测试 | 0 | **缺失** |

**评估：60%** — 核心模型和 Worker 保留完整，AASM 已落地，但 `alias_method_chain` 大量残留，Service Object 仅 4 个（原 Issue 要求从 100+ 关联中提取），无测试覆盖。

### 2.2 _backend 引擎 — 管理后台

| 指标 | 数值 | 评估 |
|------|------|------|
| 控制器数 | 226 | 全部保留 |
| API 控制器 (render json:) | 32 | 仅 14% |
| HAML 视图 | 730 | **大量残留** |
| ERB 视图 | 26 | 残留 |
| API v1 控制器 | ~14 | 新增 |
| RSpec 测试 | 10 | 极少 |

**关键问题：** _backend 是迁移质量最差的引擎。226 个控制器中仅 32 个返回 JSON，730 个 HAML 视图文件完全保留。意味着管理后台大部分页面仍走旧的 Rails 服务端渲染路径，Vue 3 Admin 应用虽然有 48 个 views，但仅覆盖了部分功能模块。

**HAML 视图残留按模块分布（前 10）：**

| 模块 | HAML 文件数 | 功能描述 |
|------|-----------|---------|
| admin | 108 | 管理员后台 |
| _promotion | 70 | 促销管理 |
| product | 38 | 商品管理 |
| wallet | 24 | 钱包/充值 |
| order | 24 | 订单管理 |
| user | 18 | 用户管理 |
| payment | 17 | 支付管理 |
| statistic | 16 | 统计报表 |
| shops | 13 | 门店管理 |
| shake_around | 13 | 摇一摇营销 |

**评估：30%** — Vue 3 Admin 应用已搭建，API v1 端点已创建，但 86% 的控制器和 96% 的视图仍是旧的 HAML 服务端渲染。实质上处于双轨并行状态。

### 2.3 _weixin 引擎 — 微信端

| 指标 | 数值 | 评估 |
|------|------|------|
| 控制器数 | 81 | 全部保留 |
| API 控制器 (render json:) | 32 | 40% |
| HTML 视图 | 23 | 少量残留 |
| API v1 端点 | 有 | 已创建 |
| RSpec 测试 | 0 | 缺失 |

**评估：65%** — API 化比例较高，HTML 视图残留较少。Vue 3 H5 应用有 16 个 views，覆盖了菜单点餐、排队、支付等核心场景。

### 2.4 _webpos 引擎 — 收银台

| 指标 | 数值 | 评估 |
|------|------|------|
| 控制器数 | 70 | 全部保留 |
| API 控制器 (render json:) | 45 | 64% |
| HAML 视图 | 10 | 少量残留 |
| ActionCable | 有 | WebPOS 实时通知 |
| Vue 3 子应用 | 7 个 | 已搭建 |

**评估：80%** — API 化比例最高，ActionCable 已集成用于后厨 KDS、排队通知、VIP 验证等。7 个 Vue 3 子应用已创建，覆盖收银台主界面、排队、账单、后厨、用户管理等。

### 2.5 _agentsys 引擎 — 代理系统

| 指标 | 数值 | 评估 |
|------|------|------|
| 控制器数 | 14 | 全部保留 |
| API 控制器 (render json:) | 1 | 仅 7% |
| HTML 视图 | 31 | 大量残留 |
| RSpec 测试 | 0 | 缺失 |

**评估：25%** — 基本未迁移。Vue 3 Agent 应用有 12 个 views 但与后端 API 不匹配。

### 2.6 API 引擎 (_oauth_api / _common_api / _inner_api)

| 引擎 | 控制器 | API (render json:) | HTML 视图 | 测试 |
|------|--------|-------------------|----------|------|
| _oauth_api | 5 | 2 | 0 | 1 (旧) |
| _common_api | 40 | 27 (68%) | 7 | 17 (旧) |
| _inner_api | 13 | 3 | 0 | 0 |

**评估：70%** — _common_api 迁移较好（68% API 化），_oauth_api 和 _inner_api 本身就是 API 引擎但 JSON render 覆盖不完整。

## 三、前端 Vue 3 应用质量

### 3.1 应用清单

| 应用 | 技术栈 | Views | TS 文件 | Tailwind | Pinia | API 集成 |
|------|--------|-------|---------|----------|-------|---------|
| admin (后台管理) | Vue 3 + Element Plus | 48 | 50 | 是 | 是 | 部分 |
| h5 (微信 H5) | Vue 3 + Vant 4 | 16 | 17 | 是 | 是 (2 stores) | 是 (4 文件) |
| agent (代理系统) | Vue 3 | 12 | 14 | 是 | 是 (1 store) | 是 (11 文件) |
| webpos (主收银台) | Vue 3 | 19 | 20 | 是 | 部分 | 是 (11 文件) |
| webpos-bill | Vue 3 | 3 | 4 | 是 | — | 部分 |
| webpos-estimate | Vue 3 | 3 | 4 | 是 | — | 部分 |
| webpos-queue | Vue 3 | 3 | 4 | 是 | — | 部分 |
| webpos-users | Vue 3 | 4 | 5 | 是 | — | 部分 |
| webpos-extended-form | Vue 3 | 3 | 4 | 是 | — | 部分 |
| webpos-kitchen | Vue 3 | 3 | 4 | 是 | — | 部分 |

**总计：** 10 个应用、135 个 .vue 文件、115 个 .ts 文件、8 个 Pinia stores

### 3.2 前端质量评估

- **TypeScript 覆盖：** 全部应用使用 TypeScript
- **Tailwind CSS：** 114/135 (84%) 的 Vue 文件使用了 Tailwind class
- **Pinia 状态管理：** 仅 3/10 应用有独立的 Pinia store，其余可能未实现复杂状态管理
- **API 集成：** agent 和 webpos 的 API 集成文件最多 (各 11 个)，admin 虽然页面最多但 API 集成文件较少
- **组件化：** 统计中 components 目录为 0，说明页面内联组件居多，未拆分复用组件

**评估：前端骨架已搭建完毕，但功能深度和组件化程度有限。**

## 四、旧模式残留统计

| 旧模式 | 文件数 | 严重度 | 说明 |
|--------|--------|--------|------|
| `alias_method_chain` | 42 | 高 | Ruby 4.0 中已不可用，必须改为 `Module#prepend` |
| `before_filter` / `around_filter` | 0 | — | 已全部替换为 `before_action` |
| `render text:` / `render nothing:` | 0 | — | 已全部清理 |
| `ar-octopus` (Octopus.using 等) | 10 | 中 | 应替换为 Rails 原生多数据库 |
| `CanCan` (Ability 文件) | 7 | 中 | 应替换为 ActionPolicy |
| HAML 视图 (全部) | ~800 | 高 | 大量残留，未完全被 Vue 3 替代 |
| CoffeeScript / AngularJS JS | ~500 | 高 | 旧前端资源仍保留 |

## 五、测试覆盖评估

| 维度 | 数值 | 评估 |
|------|------|------|
| RSpec spec 文件 | 7 | **严重不足** |
| 旧 Minitest 文件 | 216 | 保留但基于旧框架 |
| FactoryBot factories | 有 (shops, branches, accounts 等) | 基础已有 |
| Request specs (API 测试) | 1 | 极少 |
| System/Feature specs | 0 | 缺失 |
| CI | GitHub Actions | 已配置 |

**评估：测试覆盖极其薄弱。** 原有 216 个 Minitest 测试未被迁移到 RSpec，新的 RSpec 仅有 7 个文件。对于一个 752 模型、400+ 控制器的系统，测试覆盖远低于可接受水平。Phase 10 Issue 要求的核心路径测试覆盖率 >80% 目标远未达成。

## 六、关键功能模块迁移对照

### 6.1 核心业务

| 功能模块 | 后端 API | Vue 3 前端 | 测试 | 评估 |
|---------|---------|-----------|------|------|
| 商品管理 (分类/商品/规格/套餐) | 部分 API | admin 有页面 | 无 | 40% |
| 订单管理 (堂食/外卖/快餐/团购) | 部分 API | webpos + h5 有页面 | 无 | 50% |
| 支付系统 | 部分 API | 各端有页面 | 无 | 50% |
| 会员管理 (VIP/充值/积分) | 部分 API | admin 有页面 | 无 | 40% |
| 营销管理 (优惠券/促销/团购) | 部分 API | admin 有页面 | 无 | 35% |
| 统计报表 | 部分 API | admin 有页面 | 无 | 30% |
| 排队管理 | 部分 API | webpos-queue + h5 | 无 | 60% |
| 后厨显示 (KDS) | API + ActionCable | webpos-kitchen | 无 | 65% |
| 打印管理 | 部分 API | 未明确 | 无 | 20% |

### 6.2 系统功能

| 功能模块 | 状态 | 说明 |
|---------|------|------|
| 认证登录 | 已完成 | Devise 4.9 + JWT |
| 授权权限 | 未落地 | ActionPolicy Gem 已引入但代码未使用 |
| 文件上传 | 未迁移 | 仍用 CarrierWave，未切到 ActiveStorage |
| 富文本 | 未迁移 | 仍用 CKEditor，未切到 ActionText |
| WebSocket 实时通知 | 部分完成 | WebPOS 有 ActionCable，其他端未确认 |
| 消息推送 (JPush/微信/短信) | Worker 保留 | 47 个 Sidekiq Worker 完整 |
| 微信集成 | 保留 | 授权/菜单/模板消息逻辑保留 |

## 七、总体评估

### 完成度评分

| 层面 | 评分 | 说明 |
|------|------|------|
| Ruby/Rails 版本升级 | **95%** | Ruby 4.0.5 + Rails 8.1 已落地 |
| 数据库迁移 | **85%** | PostgreSQL 已切换，ar-octopus 有残留 |
| Gem 现代化 | **75%** | 主要 Gem 已升级，Discard/ActionPolicy/PaperTrail 未广泛落地 |
| 后端 API 化 | **45%** | 仅部分控制器转为 JSON API，大量仍是 HAML 服务端渲染 |
| 前端 Vue 3 重写 | **50%** | 10 个 Vue 3 应用已搭建，但页面覆盖深度有限 |
| 测试体系 | **5%** | 仅 7 个 RSpec 文件，远未达到 80% 覆盖率目标 |
| 基础设施/Docker | **90%** | Docker + Kamal 2 + CI 配置完善 |
| **综合** | **55%** | 基础架构已到位，业务层迁移深度不足 |

### 关键风险

1. **`alias_method_chain` (42 文件)** — Ruby 4.0 中此方法已不可用，运行时将直接报错。这是一个 **阻塞性问题**。
2. **测试覆盖极低** — 752 个模型仅有 7 个 spec 文件，无法验证业务逻辑正确性。
3. **_backend 双轨状态** — 730 个 HAML + 32 个 API 控制器并存，增加维护复杂度。
4. **ActionPolicy 未落地** — 授权系统处于真空状态，CanCan 已标记移除但新系统未接入。
5. **_agentsys 基本未迁移** — 代理系统 14 个控制器中仅 1 个返回 JSON。

### 建议优先事项

1. **紧急：** 修复 42 个 `alias_method_chain` → `Module#prepend`，否则系统可能无法正常启动
2. **高优：** 为核心模型 (Shop, Order, Payment, User) 补充 RSpec 测试
3. **高优：** 落地 ActionPolicy 授权，替换残留的 CanCan
4. **中优：** 完成 _backend 关键模块的 API 化（订单、商品、支付）
5. **中优：** 清理 ar-octopus 残留引用
6. **低优：** _agentsys 完整迁移
