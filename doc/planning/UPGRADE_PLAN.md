# diandantong 点单通 — 技术升级计划

> 版本：v2.0 | 日期：2026-05-27  
> 基于 /tmp/diandantong 代码库深度分析 + 官方最新版本核实（2026-05-26）

---

## 1. 现状分析

### 1.1 技术栈概览

| 层级 | 当前技术 | 版本 | 最后更新 |
|------|---------|------|---------|
| 语言 | Ruby | 2.1.6 | EOL 2017 |
| 框架 | Ruby on Rails | 4.1.13 | EOL 2015 |
| 数据库 | MySQL (utf8mb4) | 5.x | — |
| 前端框架 | AngularJS | 1.3.x | EOL 2022 |
| JS 预处理 | CoffeeScript | — | 极少使用（2文件） |
| 模板引擎 | HAML | — | 782 个视图 |
| CSS 预处理 | SCSS | — | 196 个文件 |
| CSS 框架 | Bootstrap | 3.x | EOL |
| JS 库 | jQuery | — | 全局依赖 |
| 富文本 | CKEditor | 4.1.x | — |
| 认证 | Devise | 3.4.0 | — |
| 授权 | CanCan | 1.6.10 | EOL |
| OAuth | Doorkeeper | 3.1.0 | — |
| 后台任务 | Sidekiq | 4.1.4 | — |
| 缓存 | Redis | 3.2 | — |
| WebSocket | PrivatePub (Faye) | 1.0.3 | — |
| 推送 | JPush | 3.2.1 | — |
| 服务器 | Unicorn | — | 传统 |
| 软删除 | Paranoia | 2.0.2 | — |
| 审计日志 | PaperTrail | 3.0.6 | — |
| 状态机 | state_machine + workflow | 1.2.0 / 1.2.0 | — |
| 文件上传 | CarrierWave + 阿里云 | 0.10.0 | — |
| 分页 | will_paginate | 3.0.7 | — |
| 搜索 | Ransack | 1.5.1 | — |
| 分片 | ar-octopus | — | 多主复制 |
| 定时任务 | whenever (cron) | — | + Sidekiq scheduler |
| 部署 | Foreman + Unicorn | — | 无容器化 |

### 1.2 项目规模

| 维度 | 数量 |
|------|------|
| **Rails Engines** | 8（_core, _backend, _weixin, _webpos, _agentsys, _oauth_api, _common_api, _inner_api） |
| **Models** | ~937 |
| **Controllers** | ~525 |
| **HAML Views** | 782 |
| **JS Files** | 497 |
| **SCSS Files** | 196 |
| **CoffeeScript** | 2（可忽略） |
| **DB Migrations** | 670（主 app 646 + _core 24） |
| **数据表** | ~169（从 create_table 提取） |
| **Sidekiq Workers** | 47 |
| **AngularJS SPA** | 7 个独立 app（webpos, webpos_queue, webpos_bill, webpos_kitchen, webpos_users, webpos_estimate, webpos_extended_form） |
| **Routes** | _backend 883 行, _weixin 267, _webpos 331, _common_api 253, _agentsys 45, _oauth_api 15, _inner_api 22 |
| **测试文件** | 216（Minitest，仅覆盖打印模板/优惠券/产品/排队/促销/计算器等） |
| **上传器** | 多个 CarrierWave uploader（ShopImage, ShopRectImage, ShopVipLogo, ShopButtonImage, ShopLastImportVipInfoError） |

#### Engine 职责分析

| Engine | 职责 | 路由行数 | 依赖 |
|--------|------|---------|------|
| **_core** | 核心模型、Worker、上传器、邮件、关注点 | 挂载于 `/` | 所有其他 Engine |
| **_backend** | 商家后台管理（商品/订单/会员/营销/统计/打印/系统设置） | 883 | _core |
| **_weixin** | 微信公众号/小程序前端（H5 菜单点餐/排队/支付/VIP） | 267 | _core |
| **_webpos** | Web POS 收银端（AngularJS SPA，7 个子应用） | 331 | _core |
| **_agentsys** | 代理商管理系统 | 45 | _core |
| **_oauth_api** | OAuth 2.0 授权服务（Doorkeeper） | 15 | _core |
| **_common_api** | 公共 API（给第三方/客户端调用） | 253 | _core |
| **_inner_api** | 内部 API（服务间通信） | 22 | _core |

### 1.3 依赖分析（Gem 兼容性）

#### 根 Gemfile

| Gem | 当前版本 | Rails 8 兼容 | 替代/升级方案 | 难度 |
|-----|---------|-------------|--------------|------|
| rails | 4.1.13 | ❌ | 逐步升级至 8.1 | ⭐⭐⭐⭐⭐ |
| mysql2 | 0.3.17 | ❌ | pg 1.5+ (PostgreSQL) | ⭐⭐⭐⭐ |
| exception_notification | git fork | ✅ (v4.5+) | 升级官方版本 | ⭐⭐ |
| jpush | 3.2.1 | ⚠️ | 查看最新版本或换 HTTP API | ⭐⭐ |
| foreman | 0.63.0 | ✅ | 逐步淘汰，Docker Compose 替代 | ⭐ |
| uglifier | — | ✅ | 保留或换 terser | ⭐ |
| paper_trail | 3.0.6 | ✅ | 升级至 17.x | ⭐⭐⭐ |
| settingslogic | 2.0.9 | ✅ | 保留或换 Rails.config | ⭐⭐ |
| angularjs-rails | — | ✅ | 最终移除（换 Vue 3） | ⭐⭐⭐⭐ |
| puma | — | ✅ | 升级至最新 | ⭐ |
| thin | — | ❌ | 移除，用 Puma | ⭐ |
| sass-rails | 5.0.6 | ❌ | 移除 Sprockets 管线，独立 Tailwind | ⭐⭐⭐ |
| sprockets | 2.11.0 | ❌ | Rails 8 默认仍支持但建议独立前端 | ⭐⭐⭐ |
| rack-attack | 4.3.1 | ✅ | 升级至 6.x+ | ⭐⭐ |
| ar-octopus | — | ❌ | 移除，PostgreSQL 读副本用原生方案 | ⭐⭐⭐⭐ |
| activerecord-session_store | 0.1.2 | ✅ | 升级或换 Redis session | ⭐⭐ |
| alipay | 0.14.0 (git) | ⚠️ | 换 alipay-sdk 或自封装 | ⭐⭐⭐ |
| eco | — | ✅ | 移除（CoffeeScript 模板已弃用） | ⭐ |
| sqlite3 | — | ✅ (测试) | 保留测试用 | ⭐ |
| unicorn | — | ❌ | 移除，用 Puma | ⭐ |
| quiet_assets | — | ❌ | 移除（Rails 5+ 已内置） | ⭐ |
| byebug | — | ✅ | 升级至最新 | ⭐ |
| newrelic_rpm | — | ✅ | 升级至最新 | ⭐⭐ |
| spring | — | ✅ | 可保留 | ⭐ |

#### _core Engine Gemspec（40+ 依赖）

| Gem | 当前版本 | Rails 8 兼容 | 替代方案 | 难度 |
|-----|---------|-------------|---------|------|
| friendly_id | 5.0.0 | ✅ | 升级至 5.5+ | ⭐⭐ |
| carrierwave | 0.10.0 | ✅ | 升级或换 ActiveStorage | ⭐⭐⭐ |
| carrierwave-aliyun | 0.7.0 | ⚠️ | 升级或换 ActiveStorage + S3 协议 | ⭐⭐⭐ |
| ckeditor | 4.1.0 | ⚠️ | 升级至 5.x 或换 ActionText/TipTap | ⭐⭐⭐⭐ |
| **paranoia** | 2.0.2 | ❌ | 换 **discard** | ⭐⭐⭐⭐ |
| paranoia_uniqueness_validator | 1.0.1 | ❌ | discard 自带 | ⭐⭐ |
| devise | 3.4.0 | ✅ | 升级至 4.9+，后可加 devise-jwt | ⭐⭐⭐ |
| devise-async | 0.9.0 | ⚠️ | 升级或用 ActiveJob | ⭐⭐ |
| **cancan** | 1.6.10 | ❌ | 换 **ActionPolicy** 或 Pundit | ⭐⭐⭐⭐ |
| workflow | 1.2.0 | ✅ | 升级或统一为 **AASM** | ⭐⭐⭐ |
| acts_as_list | 0.4.0 | ✅ | 升级至最新 | ⭐ |
| ransack | 1.5.1 | ✅ | 升级至 4.x+ | ⭐⭐ |
| **state_machine** | 1.2.0 | ❌ | 统一为 **AASM** | ⭐⭐⭐⭐ |
| rqrcode_png | 0.1.5 | ✅ | 升级或换 rqrcode | ⭐ |
| barby | 0.6.2 | ✅ | 升级至最新 | ⭐ |
| bcrypt-ruby | 3.0.0 | ❌ | 内置于 Rails（bcrypt gem） | ⭐ |
| sidekiq | 4.1.4 | ✅ | 升级至 8.x | ⭐⭐⭐ |
| **will_paginate** | 3.0.7 | ✅ | 换 **Pagy** | ⭐⭐⭐ |
| sinatra | ≥1.3.0 | ✅ | 升级（Sidekiq Web 依赖） | ⭐ |
| faraday | 0.9.0 | ✅ | 升级至 2.x | ⭐⭐ |
| multi_logger | 0.1.0 | ✅ | 评估是否仍需要 | ⭐ |
| httparty | 0.13.0 | ✅ | 升级至最新 | ⭐ |
| faraday-cookie_jar | 0.0.6 | ⚠️ | 升级或换 faraday-cookie_store | ⭐⭐ |
| chinese_cities | 0.0.4 | ✅ | 保留或替换数据源 | ⭐ |
| geocoder | 1.2.5 | ✅ | 升级至最新 | ⭐⭐ |
| **private_pub** (Faye) | 1.0.3 | ❌ | 换 **ActionCable** | ⭐⭐⭐⭐⭐ |
| rest-client | 1.7.2 | ✅ | 升级或统一为 Faraday | ⭐ |
| api-auth | 1.2.6 | ✅ | 升级至最新 | ⭐ |
| mini_magick | 3.4 | ✅ | 升级至最新 | ⭐⭐ |
| htmlentities | 4.3.2 | ✅ | 保留 | ⭐ |
| public_suffix | 1.4.6 | ✅ | 升级至最新 | ⭐ |
| ruby-pinyin | 0.4.5 | ✅ | 评估是否仍需要 | ⭐ |
| spreadsheet | 1.0.3 | ✅ | 换 caxlsx | ⭐⭐ |
| yajl-ruby | 1.2.1 | ✅ | 保留（JSON 解析） | ⭐ |
| font-awesome-rails | 4.5.0 | ✅ | 升级或换 CDN | ⭐ |
| easy_captcha | 0.6.4 | ⚠️ | 评估替代 | ⭐⭐ |
| activerecord-import | 0.10.0 | ✅ | 升级至最新 | ⭐⭐ |
| request_store | 1.2.0 | ✅ | 升级至最新 | ⭐ |
| rubyzip | ≥1.0.0 | ✅ | 升级至最新 | ⭐ |
| redis | 3.2 | ✅ | 升级至 8.x+ | ⭐⭐ |
| doorkeeper | 3.1.0 | ✅ | 升级至 5.x+ | ⭐⭐⭐ |
| database_cleaner | 1.3 | ✅ | 升级或换 database_cleaner-active_record | ⭐⭐ |
| factory_girl_rails | 4.4 | ❌ | 换 **factory_bot_rails** | ⭐⭐ |
| rack-attack | 4.3.1 | ✅ | 升级至 6.x+ | ⭐⭐ |

#### 关键不兼容总结

| 类型 | 需要替换的 Gem | 影响 |
|------|---------------|------|
| **授权** | cancan → ActionPolicy | 全部 Ability 文件（4个） |
| **软删除** | paranoia → discard | 所有 acts_as_paranoid 模型 |
| **状态机** | state_machine → AASM | ~15 个模型 |
| **WebSocket** | private_pub → ActionCable | 实时通知/POS 通信 |
| **DB 分片** | ar-octopus → 移除 | 所有 replicated_model 调用 |
| **工厂** | factory_girl → factory_bot | 所有测试工厂 |
| **分页** | will_paginate → Pagy | 所有分页视图 |
| **ORM** | mysql2 → pg | 所有数据库查询 |
| **CSS** | sass-rails + Bootstrap 3 → Tailwind 4 | 全部 SCSS |

### 1.4 数据库分析

#### 连接架构

```
application → ActiveRecord (master)
                ├── ar-octopus slave1 (读副本)
                ├── ar-octopus statistics (统计库)
                └── impression_* (独立印象数据库)
```

**关键发现：**
- **ar-octopus** 提供 master-slave 复制路由，从库 slave1 和统计库 stat1
- **impression** 独立数据库（impression_development / impression_production）
- 使用 `replicated_model` 宏标记需要在从库读取的模型（至少 17 个文件）
- MySQL 特有：`utf8mb4_unicode_ci` 排序规则、`DATE_FORMAT()` 函数、`CONVERT_TZ()` 函数

#### MySQL 特有语法分布

| 文件 | 语法 |
|------|------|
| `shop.rb` | `DATE_FORMAT(birthday, '%m-%d')`、`DATE_FORMAT(ddt_vip_infos.become_vip_at, '%Y-%m-%d')` |
| `shift.rb` | `DATE_FORMAT` |
| `js_errors/ddt/js_error.rb` | MySQL 特有 |
| `kitchen_setting.rb` | MySQL 特有 |
| `message/subscribe_relationship.rb` | MySQL 特有 |
| `branch_slider.rb` | MySQL 特有 |
| `coupon_photo.rb`、`groupon_line_item.rb`、`coupon.rb` | MySQL 特有 |
| `product.rb`、`variant.rb`、`variant_package.rb`、`product.rb`、`combo_package_item.rb`、`category.rb`、`option_value.rb` | MySQL 特有 |

**PostgreSQL 迁移映射：**
- `DATE_FORMAT(col, '%Y-%m-%d')` → `TO_CHAR(col, 'YYYY-MM-DD')`
- `DATE_FORMAT(col, '%m-%d')` → `TO_CHAR(col, 'MM-DD')`
- `CONVERT_TZ(t, '+00:00', '+08:00')` → `t AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai'`
- `IFNULL(a, b)` → `COALESCE(a, b)`
- `GROUP_CONCAT(col)` → `STRING_AGG(col, ',')`
- `LIMIT x OFFSET y` → 兼容，无需改动
- `utf8mb4_unicode_ci` → `UTF8`（PostgreSQL 默认支持完整 Unicode）
- `acts_as_paranoid`（deleted_at IS NULL）→ discard（相同语义，兼容）

#### 数据表概览（~169 张表）

**核心业务表：**
- `ddt_shops` — 商户（含 100+ 关联，系统最核心模型）
- `ddt_orders` — 订单（8 种子类型通过 STI）
- `ddt_line_items` — 订单明细
- `ddt_payments` / `ddt_payment_logs` — 支付
- `ddt_branches` — 门店
- `ddt_users` / `ddt_wechat_users` / `ddt_phone_users` / `ddt_web_users` — 用户体系
- `ddt_vip_infos` / `ddt_vip_levels` — VIP 会员
- `ddt_products` / `ddt_variants` / `ddt_categories` / `ddt_materials` — 商品
- `ddt_combos` / `ddt_combo_package_items` — 套餐
- `ddt_coupons` / `ddt_groupons` / `ddt_vouchers` — 营销券
- `ddt_promotions` / `ddt_promotion_rules` / `ddt_promotion_actions` — 促销引擎
- `ddt_guest_queues` / `ddt_queue_settings` — 排队
- `ddt_printers` / `ddt_print_records` / `ddt_print_codes` — 打印
- `ddt_tables` — 餐桌
- `ddt_shifts` / `ddt_shift_items` — 班次
- `ddt_wallets` / `ddt_wallet_logs` — 钱包
- `ddt_recharge_products` / `ddt_shop_recharge_records` — 充值
- `ddt_wechat_accounts` / `ddt_wechat_menus` — 微信
- `ddt_agents` / `ddt_agent_zones` — 代理商

### 1.5 前端分析

#### AngularJS SPA（_webpos）

7 个独立 AngularJS 1.3 应用，每个有自己的 `app.js`、路由、控制器、服务：

| 应用 | 功能 | 复杂度 |
|------|------|--------|
| **webpos** | 主收银台（下单/结账/退单） | 最高 |
| **webpos_queue** | 排队管理 | 中 |
| **webpos_bill** | 账单/报表 | 中 |
| **webpos_kitchen** | 后厨显示（KDS） | 中 |
| **webpos_users** | 用户管理 | 低 |
| **webpos_estimate** | 预估/统计 | 低 |
| **webpos_extended_form** | 扩展表单 | 低 |

每个应用结构：
```
webpos_xxx/
  app.js          # 模块定义 + 依赖注入
  providers/
    route_config.js   # 路由配置
    interceptor.js    # HTTP 拦截器
  controllers/
    xxx_controller.js
  services/
    xxx_service.js
```

**模块依赖链：** 所有 webpos 应用共享 `webpos_common` 和 `webpos` 公共模块。

#### _backend（HAML + jQuery）

- 883 行路由反映庞大后台管理功能
- HAML 模板 + jQuery DOM 操作 + Bootstrap 3
- CKEditor 富文本编辑器
- AJAX 表单提交（传统 Rails UJS）
- 无前端构建工具

#### _weixin（HAML + jQuery）

- 微信 H5 页面
- 菜单点餐、排队取号、在线支付、VIP 卡

#### CoffeeScript

仅 2 个文件，影响极小：
- `_backend/app/assets/javascripts/ddt/backend/bootstrap-confirm.js.coffee`
- `_backend/app/assets/javascripts/old_ddt/backend/bootstrap-confirm.js.coffee`

### 1.6 业务模块分析

#### 订单系统（6 种 + 2 辅助）

| 订单类型 | 模型 | 说明 |
|---------|------|------|
| 堂食 | `EatInHallOrder` | 在店用餐 |
| 外卖 | `DeliveryOrder` | 配送到家 |
| 快餐 | `FastfoodOrder` | 快速点餐 |
| 团购 | `GrouponOrder` | 团购消费 |
| 预订 | `ReservationOrder` | 预定座位 |
| 充值 | `RechargeOrder` | 会员充值 |
| 支付单 | `PaymentOrder` | 通用支付 |
| 叫号 | `OrderCall` | 催单 |

订单继承关系：所有子类型继承自 `Order`（ActiveRecord STI），共享 `LineItem`、`PayItem`、`FormContent`、`OrderExt`、`OrderChangeLog`。

#### 支付系统

- **支付宝**：`payment2/ddt/alipay/` 下 11 个策略类（当面付、WAP、Web、预下单、统一订单、扫码等）
- **微信支付**：v2（Legacy）+ v3.3.6 两套实现并存
- **百度支付**：`BaidupayMethod`
- **现金/刷卡/POS**：`PayOnFace` 等线下方式
- **钱包**：积分钱包、储值卡钱包、收款钱包

#### 营销引擎

- **促销**：`Promotion` → `PromotionRule` + `PromotionAction`（策略模式）
- **优惠券**：`Coupon` / `CouponVersion` / `SharableCoupon`
- **团购券**：`Groupon` / `GrouponVersion`
- **代金券**：`Voucher` / `VoucherVersion`
- **活动促销**：`EventPromotion`
- **生日促销**：`VipBirthday`（自动触发）

#### 会员系统

- VIP 等级管理
- 积分体系（积分钱包）
- 储值卡
- 生日短信 + 生日促销自动触发
- 签到记录

#### 打印系统

- 打印机管理（`Printer` / `PrinterCode`）
- 打印记录（`PrintRecord`）
- 打印模板（`BillTemplate` / 47 个测试覆盖打印逻辑）
- 前后厨分开打印
- 支持催单打印

#### 实时通信

- PrivatePub (Faye WebSocket) 用于：
  - POS 端实时订单通知
  - 后厨 KDS 实时显示
  - 排队叫号通知
  - 订单状态变更推送

#### 代理商系统

- `AgentZone` 区域代理
- `Agent` 代理商管理
- OEM 白标品牌
- 商户分配（`agent_no`）
- 代理到期检查（定时 Worker）

#### 定时任务（Sidekiq Scheduler + cron）

47 个 Worker，包括：
- 班次自动结算
- 订单自动完成
- 商户到期检查
- 代理到期检查
- VIP 生日通知
- 统计缓存清理
- 自动发券
- 外卖自动发货
- 餐桌自动清台
- 缓存清理

### 1.7 风险评估

| 风险 | 等级 | 说明 |
|------|------|------|
| Ruby/Rails 版本跨度大 | 🔴 极高 | 2.1 → 8.1 跨越 8 个大版本，10 年技术债 |
| 数据库迁移 | 🔴 极高 | MySQL → PostgreSQL，~169 张表，数据完整性 |
| 前端完全重写 | 🔴 极高 | AngularJS → Vue 3，本质是新应用 |
| ar-octopus 移除 | 🟡 高 | 读写分离逻辑散布在 17+ 文件 |
| state_machine 统一 | 🟡 高 | 两种状态机库并存，需逐模型迁移 |
| Paranoia → Discard | 🟡 高 | acts_as_paranoid 全局使用 |
| 测试覆盖不足 | 🟡 高 | 仅 216 个测试，且只覆盖打印/优惠券等 |
| PrivatePub → ActionCable | 🟡 高 | WebSocket 协议/消息格式需全部重写 |
| 支付接口兼容 | 🟡 高 | 支付宝/微信支付 SDK API 变化大 |
| 无 CI/CD | 🟠 中 | 无自动化构建/部署管线 |
| 业务逻辑耦合 | 🟠 中 | Shop 模型 100+ 关联，高耦合 |

---

## 2. 目标架构

### 2.1 技术栈选型

#### 后端

| 组件 | 选型 | 理由 |
|------|------|------|
| 语言 | Ruby 4.0.5 | 最新稳定版，长期支持 |
| 框架 | Rails 8.1 | 最新稳定版（要求 Ruby ≥ 3.2.0） |
| 数据库 | PostgreSQL 18 | 开源、JSON 支持、分区表 |
| ORM | ActiveRecord 8 | Rails 内置 |
| 认证 | Devise 4.9+ | 社区标准 |
| JWT | devise-jwt | 无状态 API 认证 |
| 授权 | ActionPolicy | 替代 CanCan，更灵活 |
| 状态机 | AASM | 替代 state_machine + workflow |
| 软删除 | Discard | 替代 Paranoia |
| 审计日志 | PaperTrail 17 | 升级现有 |
| 后台任务 | Sidekiq 8.1 | 升级现有 |
| 缓存 | Redis 8.6 | 升级现有 |
| WebSocket | ActionCable | 替代 PrivatePub |
| 分页 | Pagy | 替代 will_paginate |
| 搜索 | Ransack 4 | 升级现有 |
| 文件上传 | ActiveStorage + S3/MinIO | 替代 CarrierWave |
| 富文本 | ActionText + TipTap | 替代 CKEditor |
| 定时任务 | Sidekiq Scheduler | 统一进 Sidekiq |
| 读写分离 | Rails 6+ 多数据库 / PgBouncer | 替代 ar-octopus |
| 部署 | Kamal 2 | Docker 化部署 |

#### 前端

| 组件 | 选型 | 理由 |
|------|------|------|
| 框架 | Vue 3 + TypeScript | 现代、类型安全、生态成熟 |
| 构建 | Vite | 快速开发体验 |
| UI 库 | Element Plus | 企业级 UI 组件 |
| CSS | Tailwind CSS 4 | 实用优先 |
| 状态管理 | Pinia | Vue 3 官方推荐 |
| HTTP | Axios | 通用 HTTP 客户端 |
| 图表 | ECharts 5 | 数据可视化 |
| 表单 | VeeValidate + Zod | 表单验证 |
| 路由 | Vue Router 4 | SPA 路由 |

### 2.2 架构设计

```
┌─────────────────────────────────────────────┐
│                   Nginx                      │
│              (反向代理 / SSL)                 │
├──────────┬──────────┬───────────┬────────────┤
│  Vue SPA │  Vue SPA │  Rails   │  ActionCable│
│  Backend │  WebPOS  │  API     │  WebSocket  │
│  Admin   │  (收银台)  │  JSON    │  (实时通信)  │
├──────────┴──────────┴───────────┴────────────┤
│              Rails 8.1 Application             │
│  ┌─────────┬──────────┬──────────┬─────────┐ │
│  │ Backend │  WebPOS  │  Weixin  │  Agent  │ │
│  │ Engine  │  Engine  │  Engine  │  Engine  │ │
│  └─────────┴──────────┴──────────┴─────────┘ │
├──────────┬──────────┬────────────────────────┤
│PostgreSQL│  Redis 8.6│  Sidekiq 8.1            │
│   (主库)  │ (缓存)   │   (后台任务)            │
├──────────┴──────────┴────────────────────────┤
│              Docker + Kamal 2                 │
└─────────────────────────────────────────────┘
```

#### Engine 简化策略

**合并方案：**
- `_oauth_api` → 合并进 `_core`（15 行路由，职责单一）
- `_inner_api` → 合并进 `_core`（22 行路由）
- `_common_api` → 合并进 `_core`（统一 API 层）

**保留但重构：**
- `_backend` → 重构为 API-only，前端 Vue 独立部署
- `_weixin` → 重构为 API-only
- `_webpos` → 重构为 API-only
- `_agentsys` → 保留，API-only

**最终结构（5 → 4 Engines + API）：**
```
_core (含 API 层)
_backend (商家后台 API)
_weixin (微信端 API)
_webpos (收银端 API)
_agentsys (代理系统 API)
```

### 2.3 前后端分离策略

#### 分离原则

1. **渐进式分离**：先 API 化（加 JSON 响应），后前端独立
2. **优先级**：WebPOS → 微信 → 代理商 → 后台管理
3. **过渡期**：HAML 视图保留，Vue 新页面逐步替代

#### API 设计

- RESTful 资源路由
- JSON:API 规范或自定义 JSON 格式
- 版本化：`/api/v1/...`
- 认证：JWT (devise-jwt) + Session（过渡期）
- 分页：Pagy headers

### 2.4 Docker 化方案

```yaml
# docker-compose.yml
services:
  app:        # Rails + Puma
  sidekiq:    # Sidekiq 8.1
  postgres:   # PostgreSQL 18
  redis:      # Redis 8.6
  nginx:      # 反向代理

# Kamal 2 部署
# kamal deploy -d production
```

---

## 3. 分阶段升级计划

### Phase 0: 基础设施准备（2-3 周）

**目标：** 建立现代开发环境和 CI/CD

**入口条件：** 获取代码库访问权限  
**完成标准：** 可在本地 Docker 环境中运行当前应用

| # | 任务 | 估算 |
|---|------|------|
| 0.1 | Git 仓库规范化（.gitignore、分支策略） | 1d |
| 0.2 | Dockerfile 编写（Ruby 2.1.6 + MySQL 5.7） | 2d |
| 0.3 | docker-compose.yml（app + mysql + redis） | 2d |
| 0.4 | GitHub Actions CI 基础配置（lint + test） | 2d |
| 0.5 | Rubocop 配置（target Ruby 2.1，渐进修复） | 1d |
| 0.6 | 代码文档补充（关键模块 README） | 3d |

### Phase 1: Ruby + Rails 逐步升级（8-12 周）

**目标：** 从 Ruby 2.1 / Rails 4.1 升级到 Ruby 4.0 / Rails 8.1

**入口条件：** Phase 0 完成，所有测试通过  
**完成标准：** Rails 8.1 + Ruby 4.0，所有功能正常运行

> ⚠️ 必须逐步升级，每步验证全部功能

| # | 任务 | 估算 | 验证要点 |
|---|------|------|---------|
| 1.1 | **Rails 4.1 → 4.2** | 1w | strong_parameters、ActiveRecord::Enum、邮件预览 |
| 1.2 | **Rails 4.2 → 5.0** | 2w | Rails API、ActiveJob、ActionCable、belongs_to 必填变更、render 变更 |
| 1.3 | **Rails 5.0 → 5.1** | 1w | YAML 安全加载、secrets.yml、系统测试 |
| 1.4 | **Rails 5.1 → 5.2** | 1w | credentials、ActiveStorage 初步、Bootsnap |
| 1.5 | **Rails 5.2 → 6.0** | 2w | Zeitwerk 自动加载、多数据库、ActionMailbox、并行测试 |
| 1.6 | **Rails 6.0 → 6.1** | 1w | Strict Loading、Redis Cache Store |
| 1.7 | **Rails 6.1 → 7.0** | 2w | importmap/esbuild、Hotwire、Turbo |
| 1.8 | **Rails 7.0 → 7.1** | 1w | async queries、正常化 Ruby 关键字参数 |
| 1.9 | **Rails 7.1 → 8.0** | 2w | Propshaft/Sprockets 选择、生成式 AI 集成 |
| 1.10 | **Ruby 2.1 → 2.7** | 1w | 关键字参数变更 |
| 1.11 | **Ruby 2.7 → 3.0** | 1w | `frozen_string_literal: true`、移除 deprecated API |
| 1.12 | **Ruby 3.0 → 3.1** | 0.5w | Fiber Scheduler |
| 1.13 | **Ruby 3.1 → 3.2** | 0.5w | Data、Hash** 等新特性 |
| 1.14 | **Ruby 3.2 → 4.0** | 1w | YJIT、性能大幅提升 |

**Ruby 升级穿插策略：** 在 Rails 升级过程中同步提升 Ruby 版本。建议对应关系：
- Rails 4→5：Ruby 2.1 → 2.7
- Rails 5→6：Ruby 2.7 → 3.0
- Rails 6→7：Ruby 3.0 → 3.2
- Rails 7→8：Ruby 3.2 → 4.0

### Phase 2: 数据库迁移 MySQL → PostgreSQL（4-6 周）

**目标：** 从 MySQL 迁移到 PostgreSQL 18

**入口条件：** Phase 1 完成（至少 Rails 6.0）  
**完成标准：** PostgreSQL 运行，所有功能验证通过

| # | 任务 | 估算 |
|---|------|------|
| 2.1 | 添加 PostgreSQL adapter，双写模式（同时写 MySQL + PG） | 3d |
| 2.2 | 替换 MySQL 特有语法（DATE_FORMAT → TO_CHAR 等） | 1w |
| 2.3 | 移除 ar-octopus，用 Rails 多数据库方案替代 | 1w |
| 2.4 |impression 数据库合并到主库 | 2d |
| 2.5 | 数据迁移脚本（Schema + Data） | 1w |
| 2.6 | 切换读取到 PostgreSQL，验证一致性 | 3d |
| 2.7 | 移除 MySQL 依赖，清理配置 | 2d |
| 2.8 | PostgreSQL 性能调优（索引、查询计划分析） | 3d |

### Phase 3: Gem 依赖现代化（6-8 周）

**目标：** 替换所有不兼容/过时的 Gem

**入口条件：** Phase 1 完成（Rails 8.1）  
**完成标准：** 所有 Gem 升级到最新兼容版本

| # | 任务 | 依赖 Gem | 估算 |
|---|------|---------|------|
| 3.1 | cancan → ActionPolicy | 授权 | 2w |
| 3.2 | paranoia → discard | 软删除 | 1w |
| 3.3 | state_machine → AASM | 状态机统一 | 2w |
| 3.4 | workflow → AASM | 状态机统一 | 1w |
| 3.5 | will_paginate → Pagy | 分页 | 1w |
| 3.6 | private_pub → ActionCable | WebSocket | 2w |
| 3.7 | CarrierWave → ActiveStorage | 文件上传 | 2w |
| 3.8 | CKEditor → ActionText + TipTap | 富文本 | 1w |
| 3.9 | Devise 3.4 → 4.9 | 认证 | 1w |
| 3.10 | Doorkeeper 3.1 → 5.x | OAuth | 1w |
| 3.11 | Sidekiq 4.1 → 8.x | 后台任务 | 1w |
| 3.12 | factory_girl → factory_bot | 测试 | 2d |
| 3.13 | 其他 Gem 升级（见 1.3 对照表） | 各种 | 1w |
| 3.14 | 移除不需要的 Gem（thin, unicorn, eco, sqlite3-prod） | 清理 | 2d |

**执行顺序很重要：**
1. 先换分页（Pagy）— 影响面小
2. 再换软删除（Discard）— 全局影响但模式一致
3. 然后换状态机（AASM）— 需逐模型迁移
4. 再换授权（ActionPolicy）— 需重写所有 Ability
5. 最后换 WebSocket（ActionCable）— 最复杂

### Phase 4: 前端现代化（12-16 周）

**目标：** AngularJS + jQuery + HAML → Vue 3 + TypeScript + Vite

**入口条件：** Phase 3 完成（API 化）  
**完成标准：** 所有前端页面迁移到 Vue 3 SPA

#### 4A: API 化（4 周）

| # | 任务 | 估算 |
|---|------|------|
| 4A.1 | 设计统一 API 规范（响应格式、错误处理、分页） | 1w |
| 4A.2 | _webpos API 化（现有控制器加 JSON 响应） | 1w |
| 4A.3 | _weixin API 化 | 1w |
| 4A.4 | _backend API 化 | 1w |

#### 4B: WebPOS Vue 3 重写（4 周）

**优先级最高** — 收银端是日常高频使用

| # | 任务 | 估算 |
|---|------|------|
| 4B.1 | Vue 3 + Vite 项目初始化（monorepo：webpos, queue, kitchen, bill） | 2d |
| 4B.2 | 通用组件库（Layout、Table、Form、Dialog） | 1w |
| 4B.3 | webpos（主收银台）迁移 | 1.5w |
| 4B.4 | webpos_queue（排队管理）迁移 | 3d |
| 4B.5 | webpos_kitchen（后厨 KDS）迁移 | 3d |
| 4B.6 | webpos_bill（账单报表）迁移 | 3d |
| 4B.7 | webpos_users + webpos_estimate 迁移 | 2d |

#### 4C: 后台管理 Vue 3 重写（4 周）

| # | 任务 | 估算 |
|---|------|------|
| 4C.1 | Vue Admin 项目初始化（基于 Vue 3 + Element Plus） | 2d |
| 4C.2 | 登录/权限/布局 | 3d |
| 4C.3 | 商户设置 | 3d |
| 4C.4 | 商品管理（分类/商品/规格/套餐） | 1w |
| 4C.5 | 订单管理（各类型订单） | 1w |
| 4C.6 | 会员管理（VIP/充值/积分） | 3d |
| 4C.7 | 营销管理（优惠券/促销/活动） | 5d |
| 4C.8 | 统计报表 | 5d |
| 4C.9 | 打印管理、排队管理、系统设置 | 5d |

#### 4D: 微信端 Vue 3 重写（2-3 周）

| # | 任务 | 估算 |
|---|------|------|
| 4D.1 | 微信 H5 项目初始化（Vue 3 + 移动端 UI） | 2d |
| 4D.2 | 微信授权/登录 | 2d |
| 4D.3 | 菜单点餐 | 5d |
| 4D.4 | 排队取号 | 3d |
| 4D.5 | 在线支付 | 3d |
| 4D.6 | VIP 中心 | 3d |

#### 4E: 代理商系统 Vue 3 重写（1-2 周）

| # | 任务 | 估算 |
|---|------|------|
| 4E.1 | 代理系统 Vue 3 项目 | 2d |
| 4E.2 | 商户管理/到期管理/品牌配置 | 5d |

### Phase 5: 业务逻辑重构（4-6 周）

**目标：** 优化核心业务逻辑，消除技术债

**入口条件：** Phase 3 + Phase 4 至少 4A 完成  
**完成标准：** 核心业务逻辑清晰、可测试

| # | 任务 | 估算 |
|---|------|------|
| 5.1 | Shop 模型解耦（100+ 关联 → Service Object 模式） | 2w |
| 5.2 | 订单系统重构（提取 OrderService、PaymentService） | 2w |
| 5.3 | 支付系统统一（移除旧版本，统一支付网关接口） | 1w |
| 5.4 | 营销引擎重构（规则引擎模式） | 1.5w |
| 5.5 | 推送系统统一（JPush + 微信模板消息 + 短信） | 1w |

### Phase 6: 性能优化 & 测试（4-6 周）

**目标：** 建立完善的测试体系和性能基线

**入口条件：** Phase 5 完成  
**完成标准：** 核心路径测试覆盖率 > 80%

| # | 任务 | 估算 |
|---|------|------|
| 6.1 | 测试框架升级（Minitest → RSpec） | 3d |
| 6.2 | Factory Bot 迁移 + 完善测试数据 | 1w |
| 6.3 | 核心模型测试（Shop, Order, Payment, User） | 1w |
| 6.4 | 业务逻辑测试（订单流程、支付流程、促销引擎） | 1w |
| 6.5 | API 集成测试（Request Specs） | 1w |
| 6.6 | 前端 E2E 测试（Playwright） | 1w |
| 6.7 | 性能基线建立 + 优化（N+1 查询、缓存策略） | 1w |

### Phase 7: Docker 化 & 部署（3-4 周）

**目标：** 完整的容器化部署方案

**入口条件：** Phase 4 + Phase 6 基本完成  
**完成标准：** 可通过 Kamal 一键部署到生产环境

| # | 任务 | 估算 |
|---|------|------|
| 7.1 | 生产 Dockerfile 优化（多阶段构建） | 2d |
| 7.2 | docker-compose.prod.yml（app + sidekiq 8.1 + postgres 18 + redis 8.6 + nginx） | 3d |
| 7.3 | Kamal 2 配置（deploy.yml、accessories） | 2d |
| 7.4 | 数据库迁移策略（零停机迁移） | 2d |
| 7.5 | SSL 证书自动化（Let's Encrypt） | 1d |
| 7.6 | 监控告警（Prometheus + Grafana 或 NewRelic） | 3d |
| 7.7 | 日志收集（ELK 或 Loki） | 2d |
| 7.8 | 备份策略（PostgreSQL + Redis + 文件） | 2d |
| 7.9 | 灰度发布方案 | 2d |

---

## 4. 各 Phase 详细任务分解

### Phase 1 详细 Issue 模板

#### Issue: 升级 Rails 4.1 → 4.2

```markdown
**标题:** [Phase 1.1] 升级 Rails 4.1 → 4.2

**描述:**
将 Rails 从 4.1.13 升级到 4.2.x（最后一个 4.2 版本）

**变更清单:**
- [ ] Gemfile: rails '4.2.x'
- [ ] config/secrets.yml 配置
- [ ] strong_parameters 全面启用（替代 attr_accessible）
- [ ] ActiveRecord::Enum 替换硬编码常量
- [ ] 邮件预览功能配置
- [ ] 检查所有 deprecated 警告
- [ ] Gem 兼容性检查更新
- [ ] 全功能回归测试

**影响范围:** 全部
**预估工时:** 5 人天
**验收标准:** 所有页面功能正常，无 deprecation 警告
```

#### Issue: 替换 ar-octopus → Rails 多数据库

```markdown
**标题:** [Phase 2.3] 移除 ar-octopus，使用 Rails 多数据库方案

**描述:**
ar-octopus 已不再维护，需要迁移到 Rails 原生多数据库支持。

**步骤:**
1. 列出所有使用 replicated_model 的文件（已确认 17+ 个）
2. 识别所有 Octopus.using(:slave) / Octopus.using(:statistics) 调用
3. 配置 Rails 6+ 多数据库（database.yml 中定义 roles）
4. 重写连接路由逻辑
5. 使用 `connects_to` 宏替换 `replicated_model`
6. 逐步测试每个读写分离场景

**已知受影响模型:**
- Ddt::Shop（核心）
- Ddt::Order 及子类
- Ddt::Payment
- Ddt::GuestQueue
- Ddt::Branch
- Ddt::Variant
- Ddt::Product
- Ddt::Category
- 等等...

**预估工时:** 5 人天
```

#### Issue: PrivatePub → ActionCable

```markdown
**标题:** [Phase 3.6] 替换 PrivatePub (Faye) → ActionCable

**描述:**
PrivatePub 基于 Faye，已过时。迁移到 Rails 原生 ActionCable。

**影响范围:**
- POS 端实时订单推送
- 后厨 KDS 实时显示
- 排队叫号通知
- 微信端消息推送

**步骤:**
1. 分析现有 Faye 频道和消息格式
2. 设计 ActionCable 频道结构
3. 创建对应 Channel 类
4. 迁移后端发布逻辑
5. 迁移前端订阅逻辑
6. Redis adapter 配置
7. 并行运行测试（Faye + ActionCable 同时推送）
8. 切换并移除 Faye

**预估工时:** 10 人天
```

---

## 5. 风险与缓解措施

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| Rails 升级中途卡住 | 项目延期 | 每步升级都保留回退分支；优先解决阻塞问题 |
| 数据迁移丢失 | 数据不可恢复 | 先完整备份；双写模式过渡；数据校验脚本 |
| 前端重写周期过长 | 业务停滞 | 渐进式替代，保持旧版可用；优先迁移高频页面 |
| 支付接口变化 | 收入中断 | 保持旧版 SDK 兼容层；灰度切换；提前测试沙箱 |
| 第三方 Gem 不兼容 | 功能缺失 | 提前验证；准备 fork 或替代方案 |
| 团队技能不足 | 质量问题 | 培训计划；外部咨询；结对编程 |
| 测试覆盖不足 | 回归缺陷 | 边升级边补测试；自动化冒烟测试 |
| 业务中断 | 客户流失 | 灰度发布；回滚方案；客户提前通知 |

---

## 6. 时间与资源估算

### 总体时间线

| Phase | 描述 | 周数 | 累计 |
|-------|------|------|------|
| Phase 0 | 基础设施准备 | 2-3w | 3w |
| Phase 1 | Ruby + Rails 升级 | 8-12w | 15w |
| Phase 2 | 数据库迁移 | 4-6w | 21w |
| Phase 3 | Gem 现代化 | 6-8w | 29w |
| Phase 4 | 前端现代化 | 12-16w | 45w |
| Phase 5 | 业务重构 | 4-6w | 51w |
| Phase 6 | 性能 & 测试 | 4-6w | 57w |
| Phase 7 | Docker 化 & 部署 | 3-4w | 61w |

**总计：约 12-15 个月**（2-3 名全职开发人员）

### 资源需求

| 角色 | 人数 | 职责 |
|------|------|------|
| 高级 Ruby/Rails 开发 | 1-2 | 后端升级 + 业务重构 |
| Vue/前端开发 | 1-2 | 前端重写 |
| DevOps | 0.5 | Docker + CI/CD + 部署 |
| DBA | 0.5 | 数据库迁移（按需） |
| 测试 | 1 | 测试编写 + 回归测试 |

### 并行化建议

- **Phase 1-3** 可部分并行（Gem 升级穿插在 Rails 升级中）
- **Phase 4 前端** 可在 Phase 2 完成后开始（先 API 化，再重写前端）
- **Phase 6 测试** 贯穿始终，不需要等 Phase 5 完成

---

## 7. 附录

### A. Gem 兼容性对照表

见 [1.3 依赖分析](#13-依赖分析gem-兼容性) 完整表格。

### B. 数据库迁移映射

#### MySQL → PostgreSQL 类型映射

| MySQL 类型 | PostgreSQL 类型 | 说明 |
|-----------|----------------|------|
| `INT` | `INTEGER` | 兼容 |
| `BIGINT` | `BIGINT` | 兼容 |
| `VARCHAR(n)` | `VARCHAR(n)` | 兼容 |
| `TEXT` | `TEXT` | 兼容 |
| `LONGTEXT` | `TEXT` | PG TEXT 无长度限制 |
| `DATETIME` | `TIMESTAMP` | 注意时区 |
| `TIMESTAMP` | `TIMESTAMP` | 注意时区 |
| `DECIMAL(m,n)` | `DECIMAL(m,n)` | 兼容 |
| `FLOAT` | `DOUBLE PRECISION` | PG FLOAT 精度更高 |
| `TINYINT(1)` | `BOOLEAN` | 布尔类型 |
| `JSON` | `JSONB` | PG 原生 JSON 查询 |
| `BLOB` | `BYTEA` | 二进制 |
| `ENUM('a','b')` | `VARCHAR` + CHECK | PG 无原生 ENUM（或使用 CREATE TYPE） |
| `AUTO_INCREMENT` | `SERIAL` / `GENERATED ALWAYS AS IDENTITY` | 自增主键 |

#### 函数映射

| MySQL | PostgreSQL |
|-------|-----------|
| `DATE_FORMAT(col, '%Y-%m-%d')` | `TO_CHAR(col, 'YYYY-MM-DD')` |
| `DATE_FORMAT(col, '%m-%d')` | `TO_CHAR(col, 'MM-DD')` |
| `CONVERT_TZ(col, '+00:00', '+08:00')` | `col AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai'` |
| `IFNULL(a, b)` | `COALESCE(a, b)` |
| `GROUP_CONCAT(col)` | `STRING_AGG(col::TEXT, ',' ORDER BY col)` |
| `NOW()` | `NOW()` | 兼容 |
| `CURDATE()` | `CURRENT_DATE` | 兼容 |
| `LIMIT 10 OFFSET 20` | `LIMIT 10 OFFSET 20` | 兼容 |
| `REPLACE(col, 'a', 'b')` | `REPLACE(col, 'a', 'b')` | 兼容 |
| `CONCAT(a, b)` | `a \|\| b` 或 `CONCAT(a, b)` | 兼容 |
| `LIKE '%keyword%'` | `LIKE '%keyword%'` | 兼容（大小写敏感需 ILIKE） |

### C. API 路由清单

#### _backend（883 行路由 — 核心 API）

主要资源（从路由文件提取的关键控制器）：
- `api_keys`, `sms_captchas`, `short_messages`, `js_errors`, `register_forms`
- `app_versions`, `jokes`, `qr_code_scenes`, `qr_code_assign_logs`
- `variant_images`, `combo_images`, `asset_tags`, `pre_sale_staffs`, `sale_employees`
- `admin_statistics`, `censor_reports`, `withdraws`
- 商品管理、订单管理、会员管理、营销管理、打印管理、统计报表、系统设置等

#### _weixin（267 行路由）
- 微信菜单、点餐、排队、支付、VIP

#### _webpos（331 行路由）
- POS 登录、商品、下单、支付、退单、打印、班次

#### _common_api（253 行路由）
- 公共 API 端点

#### _agentsys（45 行路由）
- 代理登录、商户管理

#### _oauth_api（15 行路由）
- Doorkeeper OAuth 端点

#### _inner_api（22 行路由）
- 内部服务间通信

### D. AngularJS → Vue 3 组件映射

| AngularJS 概念 | Vue 3 对应 | 说明 |
|---------------|-----------|------|
| `angular.module()` | `createApp()` | 应用创建 |
| `.controller()` | Composition API `setup()` | 逻辑编写 |
| `.service()` / `.factory()` | `provide/inject` | 依赖注入 |
| `.directive()` | 自定义组件 + composables | 指令/组件 |
| `ng-route` / `ui-router` | Vue Router 4 | 路由 |
| `$http` | Axios | HTTP 请求 |
| `$scope.$watch` | `watch()` / `computed()` | 响应式 |
| `$scope.$emit/$broadcast` | 事件总线 / Pinia | 状态通信 |
| `$timeout` / `$interval` | `setTimeout` / `setInterval` | 定时器 |
| `ng-repeat` | `v-for` | 列表渲染 |
| `ng-if` / `ng-show` | `v-if` / `v-show` | 条件渲染 |
| `ng-model` | `v-model` | 双向绑定 |
| `ng-class` | `:class` | 动态 class |
| `ng-click` | `@click` | 事件绑定 |
| Filters | computed / 方法 | 数据格式化 |

### E. 状态机迁移映射

#### state_machine → AASM

```ruby
# 旧代码 (state_machine)
state_machine :state, initial: :pending do
  event :pay do
    transition pending: :paid
  end
  event :complete do
    transition paid: :completed
  end
end

# 新代码 (AASM)
include AASM

aasm column: :state, no_direct_assignment: true do
  state :pending, initial: true
  state :paid
  state :completed

  event :pay do
    transitions from: :pending, to: :paid
  end
  event :complete do
    transitions from: :paid, to: :completed
  end
end
```

#### workflow → AASM

```ruby
# 旧代码 (workflow)
include Workflow
workflow do
  state :pending do
    event :pay, transitions_to: :paid
  end
  state :paid do
    event :complete, transitions_to: :completed
  end
end

# 新代码 (AASM) — 同上
```

### F. 订单类型 STI 继承关系

```
Ddt::Order (STI base)
├── Ddt::EatInHallOrder    # 堂食
├── Ddt::DeliveryOrder      # 外卖
├── Ddt::FastfoodOrder      # 快餐
├── Ddt::GrouponOrder       # 团购
├── Ddt::ReservationOrder   # 预订
├── Ddt::RechargeOrder      # 充值
├── Ddt::PaymentOrder       # 支付单
└── Ddt::OrderCall          # 催单
```

关联模型：
- `LineItem` — 订单明细
- `PayItem` — 支付项
- `FormContent` — 表单内容
- `OrderExt` — 扩展信息
- `OrderChangeLog` — 变更日志

### G. 官方版本参考（2026-05-26 核实）

> 所有版本号已通过官方渠道核实，确保为截至 2026-05-26 的最新稳定版本。

#### Ruby

| 版本 | 发布日期 | 状态 | 说明 |
|------|---------|------|------|
| **4.0.5** | 2026-05-20 | ✅ 正常维护 | **最新稳定版，推荐使用** |
| 4.0.4 | 2026-05-11 | 正常维护 | |
| 4.0.3 | 2026-04-21 | 正常维护 | |
| 3.4.9 | 2026-03-11 | 正常维护 | 3.x 系列最新 |
| 3.3.11 | 2026-03-26 | 安全维护 | 正常维护至 2026-04-01 已结束 |
| 3.2.11 | 2026-03-27 | ❌ EOL | 2026-04-01 终止 |

- Ruby 4.0 发布于 2025-12-25
- Ruby 3.2 已于 2026-04-01 进入 EOL
- 参考：https://www.ruby-lang.org/en/downloads/releases/
- 分支状态：https://www.ruby-lang.org/en/downloads/branches/

#### Ruby on Rails

| 版本 | 发布日期 | 说明 |
|------|---------|------|
| **8.1.3** | 2026-03-24 | **最新稳定版，推荐使用** |
| 要求 Ruby ≥ 3.2.0 | | |

- 维护策略：小版本发布后 1 年 bug 修复，2 年安全修复
- 参考：https://rubygems.org/gems/rails
- 维护政策：https://guides.rubyonrails.org/maintenance_policy.html

#### PostgreSQL

| 版本 | 当前补丁 | 支持 | 首次发布 | 终止支持 |
|------|---------|------|---------|---------|
| **18** | **18.4** | ✅ 是 | 2025-09-25 | 2030-11-14 |
| 17 | 17.10 | ✅ 是 | 2024-09-26 | 2029-11-08 |
| 16 | 16.14 | ✅ 是 | 2023-09-14 | 2028-11-09 |
| 15 | 15.18 | ✅ 是 | 2022-10-13 | 2027-11-11 |
| 14 | 14.23 | ✅ 是 | 2021-09-30 | 2026-11-12 |
| 13 | 13.23 | ❌ 否 | 2020-09-24 | 2025-11-13 |

- 每个大版本支持 5 年
- 参考：https://www.postgresql.org/support/versioning/

#### Sidekiq

| 版本 | 发布日期 |
|------|---------|
| **8.1.5** | 2026-05-13 |
| 8.1.4 | 2026-05-07 |
| 8.1.3 | 2026-04-16 |
| 8.0.10 | 2025-12-01 |
| 8.0.0 | 2025-03-05 |

- 参考：https://rubygems.org/gems/sidekiq/versions

#### Redis

| 版本 | 发布日期 | 活跃支持 | 安全支持 | 最新补丁 |
|------|---------|---------|---------|----------|
| **8.6** | 2026-02-11 | ✅ 是 | ✅ 是 | 8.6.3 (2026-05-05) |
| 8.4 | 2025-11-18 | ❌ 已结束 | ✅ 是 | 8.4.3 |
| 8.2 | 2025-08-04 | ❌ 已结束 | ✅ 是 | 8.2.6 |
| 8.0 | 2025-05-02 | ❌ 已结束 | ❌ 已结束 | 8.0.6 |
| 7.4 | 2024-07-29 | ❌ 已结束 | ✅ 是 | 7.4.9 |
| 7.2 | 2023-08-15 | ❌ 已结束 | ✅ 是 | 7.2.14 |

- Redis 8.x 采用 RSALv2/SSPLv1 双许可证（7.4+ 开始）
- 参考：https://endoflife.date/redis
- 官方下载：https://redis.io/download/

#### Rails 多数据库

- Rails 6+ 原生支持多数据库（`connects_to`）
- 参考：https://guides.rubyonrails.org/active_record_multiple_databases.html

---

> **文档维护说明：** 随着升级进展，持续更新此文档。每个 Phase 完成后标记状态，记录实际工时与偏差。
