# Phase 0: Database Migration Baseline Report

Date: 2026-05-27
Branch: feat/phase0-database-migration-baseline
Base: dev (git@bitbucket.org:siko/diandantong.git)

## 1. Migration File Inventory

| Source | Count | Date Range |
|--------|-------|------------|
| Main app (`db/migrate/`) | **646** | 2015-04-16 ~ 2016-12-20 |
| _core engine (`_core/db/migrate/`) | **24** | 2014-12-22 ~ 2015-05-08 |
| Other engines (_backend, _weixin, _agentsys, _webpos, _oauth_api, _common_api, _inner_api) | **0** | N/A |
| **Total** | **670** | |

## 2. Table Inventory

**169 unique tables** found via `create_table` calls across all migrations.

### Table Prefix Distribution

All application tables use the `ddt_` prefix (167 tables), plus 2 non-prefixed system tables:
- `ckeditor_assets`
- `impressions`
- `versions` (PaperTrail)

### Core Business Tables (by domain)

**Order Management:**
- ddt_orders, ddt_line_items, ddt_shipments, ddt_payments, ddt_adjustments
- ddt_order_change_logs, ddt_invoices, ddt_service_product_orders

**Product Catalog:**
- ddt_products, ddt_variants, ddt_categories, ddt_categories_products
- ddt_option_types, ddt_option_values, ddt_option_values_variants
- ddt_product_option_types, ddt_tags, ddt_products_tags

**Combo/Package:**
- ddt_combos, ddt_combo_items, ddt_combo_items_variants
- ddt_combo_packages, ddt_combo_package_items, ddt_combos_combo_images

**Promotion/Coupon:**
- ddt_promotions, ddt_promotion_actions, ddt_promotion_rules
- ddt_promotions_branches, ddt_promotions_line_items, ddt_promotions_orders
- ddt_base_coupons, ddt_sharable_coupons, ddt_coupon_photos

**User/Account:**
- ddt_accounts, ddt_base_users, ddt_roles, ddt_accounts_roles
- ddt_vip_infos, ddt_vip_levels, ddt_wallets, ddt_wallet_logs

**Shop/Branch:**
- ddt_shops, ddt_branches, ddt_branches_zones, ddt_branch_types
- ddt_branch_sliders, ddt_tables, ddt_table_zones, ddt_zones

**Delivery:**
- ddt_delivery_ranges, ddt_delivery_settings, ddt_delivery_fee_settings
- ddt_delivery_modules, ddt_delivery_times, ddt_delivery_zones

**Payment:**
- ddt_payment_methods, ddt_pay_method_settings, ddt_withdraws

**WeChat:**
- ddt_wechat_accounts, ddt_wechat_menus, ddt_wechat_users
- ddt_wechat_share_records, ddt_wechat_subscribe_relationships
- ddt_wechatpay_feedbacks, ddt_wechatpay_warnings, ddt_wechat_view_records

**Agent/Merchant:**
- ddt_agents, ddt_agent_logs, ddt_agent_materials, ddt_agent_rels
- ddt_agent_zones, ddt_merchant_applies

**Queue/Reservation:**
- ddt_guest_queues, ddt_guest_queue_dequeued_events
- ddt_guest_queue_notifications, ddt_reservation_infos

**Other:**
- ddt_assets, ddt_comments, ddt_printers, ddt_print_records
- ddt_notifications, ddt_events, ddt_search_groups, etc.

## 3. Schema Statistics

| Metric | Count |
|--------|-------|
| Column definitions (`t.string`, `t.integer`, etc.) | **1,959** |
| Index definitions (`add_index`) | **642** |
| Schema modifications (`remove_column`, `rename_column`, `change_column`, etc.) | **274** |
| `add_column` across files | **319 files** |
| Table renames/drops | **35** |
| `change_table` calls | **2** |
| Files with raw `execute()` SQL | **84** |

## 4. MySQL-Specific Syntax (Critical Blockers)

**12 files** contain MySQL-specific SQL that will NOT execute on PostgreSQL. These are the critical blockers for `db:migrate` on PG.

### 4.1 `CREATE TABLE ... LIKE` (4 files)

Used for table copy-and-migrate pattern (copy table, add columns, copy data, rename).

| File | Table Affected |
|------|---------------|
| `20160130100002_add_itemable_info_to_line_item.rb` | ddt_line_items |
| `20160130100008_add_shipment_info_to_order.rb` | ddt_orders |
| `20160130100023_move_change_merge_table_record_to_order_change_log.rb` | ddt_order_change_logs |
| `20160130100024_add_pay_method_info_to_pay_item.rb` | ddt_pay_items |

**PostgreSQL alternative:** `CREATE TABLE new AS SELECT * FROM old WHERE 1=0` (copies structure without data), then manually add columns.

### 4.2 `GROUP_CONCAT()` (1 file)

| File | Line | Usage |
|------|------|-------|
| `20160130100002_add_itemable_info_to_line_item.rb` | 51 | `GROUP_CONCAT(c.name SEPARATOR ' ')` |

**PostgreSQL alternative:** `STRING_AGG(c.name, ' ')`

### 4.3 `IF()` function (4 files)

| File | Lines | Usage |
|------|-------|-------|
| `20160130100008_add_shipment_info_to_order.rb` | 58-61 | `IF()` for conditional display text |
| `20161102104634_add_level_to_vip_level.rb` | 11-16 | Nested `IF()` with session variables |
| `20160130121751_fix_order_number_prefix.rb` | 4 | `IF(number REGEXP ...)` |
| `20160419152744_fix_wx_link.rb` | 6,12,18,24 | Nested `IF()` with `REGEXP` |

**PostgreSQL alternative:** `CASE WHEN ... THEN ... ELSE ... END`

### 4.4 `DATE_FORMAT()` (2 files)

| File | Lines | Usage |
|------|-------|-------|
| `20160130100008_add_shipment_info_to_order.rb` | 60 | `DATE_FORMAT(t.start_time, '%H:%i')` |
| `20160130100016_add_reservation_info_to_order.rb` | 15 | `DATE_FORMAT(info.time_point, '%H:%i')` |
| `20161213043749_fix_refund_completed_shift.rb` | 6, 11 | `DATE_FORMAT(updated_at, '%Y-%m-%d')` |

**PostgreSQL alternative:** `TO_CHAR(column, 'HH24:MI')` or `TO_CHAR(column, 'YYYY-MM-DD')`

### 4.5 `REGEXP` operator (4 files)

| File | Lines |
|------|-------|
| `20160130100027_add_product_name_to_line_item.rb` | 6,11,17 |
| `20160130121751_fix_order_number_prefix.rb` | 4 |
| `20160419152744_fix_wx_link.rb` | 6,12,18,24 |
| `20160420154737_fix_link.rb` | 6,11,16 |

**PostgreSQL alternative:** `~` operator (POSIX regex) or `SIMILAR TO`

### 4.6 `CHARACTER SET` / `COLLATE` (1 file)

| File | Line |
|------|------|
| `20160130100008_add_shipment_info_to_order.rb` | 45 |

**PostgreSQL alternative:** Remove these clauses; PG uses `CREATE DATABASE ... ENCODING 'UTF8'` at DB level.

### 4.7 MySQL Session Variables (1 file)

| File | Lines | Usage |
|------|-------|-------|
| `20161102104634_add_level_to_vip_level.rb` | 11-16 | `@pre_shop_id`, `@pre_level` session variables |

**PostgreSQL alternative:** Use a PL/pgSQL function or CTE with window functions (`ROW_NUMBER()`).

### 4.8 MySQL `SET autocommit=0` (4 files)

Same files as 4.1 (`CREATE TABLE ... LIKE` pattern). Uses `SET autocommit=0` / `SET autocommit=1` for transaction control.

**PostgreSQL alternative:** Use standard `BEGIN` / `COMMIT` blocks (which Rails already wraps migrations in).

## 5. MySQL-Specific Syntax (Non-Blocking)

These patterns are MySQL-specific but handled by ActiveRecord's abstraction layer and won't necessarily block `db:migrate`:

| Pattern | Count | Note |
|---------|-------|------|
| `:string, limit: N` | ~30+ files | Maps to `varchar(N)` in PG; works as-is |
| `:binary, limit: 10.megabyte` | 1 file | Maps to `bytea` in PG; may need adjustment |
| `unsigned: true` (if present) | TBD | PG has no unsigned; would need CHECK constraint |

## 6. Data Integrity Assessment

### Foreign Keys
- **No `add_foreign_key` calls found** in any migration file
- Referential integrity is enforced at the application level only
- No database-level foreign key constraints exist

### Indexes
- **642 index definitions** across all migrations
- Most are standard B-tree indexes
- No FULLTEXT or SPATIAL indexes detected

### Default Values
- Common defaults: `false` for booleans, `0` for integers
- Some columns use `nil`/`NULL` as default (explicit or implicit)
- No MySQL-specific default functions (e.g., `ON UPDATE CURRENT_TIMESTAMP`) detected

## 7. Risk Assessment

### High Risk (Will block db:migrate on PostgreSQL)
1. **4 files using `CREATE TABLE ... LIKE`** - Must rewrite with PG-compatible table copy
2. **12 files with MySQL-specific SQL functions** - Must rewrite all raw SQL

### Medium Risk
1. **84 files with `execute()` calls** - Each must be audited for MySQL-specific syntax
2. **No foreign keys** - Data integrity depends entirely on application logic
3. **Table rename/drop patterns** - Some migrations rename and swap tables

### Low Risk
1. **String limits** - ActiveRecord handles these correctly for PG
2. **Date/time columns** - Standard Rails migration types map correctly
3. **Boolean defaults** - Standard patterns work across adapters

## 8. Recommendations for Phase 1 (MySQL → PostgreSQL Migration)

1. **Schema-first approach:** Generate `schema.rb` from MySQL first, then create a clean PG-compatible version
2. **Data migration:** Use `pgloader` or custom scripts for data transfer
3. **Rewrite 12 critical files** with PostgreSQL-compatible SQL before attempting `db:migrate`
4. **Add foreign keys** during migration for data integrity
5. **Test migration on staging** with a copy of production data
6. **Consider squashing migrations** - 670 migrations over 2 years can be consolidated

## 9. Conclusion

The database has 169 tables with ~1,959 columns and 642 indexes, managed by 670 migration files. The migration history spans from 2014-12 to 2016-12. **12 files contain MySQL-specific SQL that must be rewritten before migrating to PostgreSQL.** No `schema.rb` baseline exists yet, so one should be generated from the MySQL database as the first step of any migration effort.
