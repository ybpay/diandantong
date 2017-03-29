class CreateDeliveryRanges < ActiveRecord::Migration
  def change

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "ddt_abstract_coupon_versions", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "usable_starts_at"
    t.datetime "usable_expires_at"
    t.integer  "max_grant_limit",                                                               default: 1000000
    t.string   "coupon_appliable_branch_scope_policy",                                          default: "appliable_to_part_branch"
    t.integer  "base_coupons_count",                                                            default: 0
    t.integer  "refund_coupons_count",                                                          default: 0
    t.integer  "shop_id"
    t.datetime "deleted_at"
    t.text     "description",                          limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "groupon_price",                                         precision: 8, scale: 2, default: 10.0
    t.decimal  "norminal_value",                                        precision: 8, scale: 2, default: 10.0
    t.boolean  "support_refund_any_time",                                                       default: true
    t.boolean  "support_refund_after_expired",                                                  default: true
    t.text     "applicaple_product_scope",             limit: 16777215
    t.datetime "sellable_starts_at"
    t.datetime "sellable_expires_at"
    t.decimal  "coupon_min_usable_amount",                              precision: 8, scale: 2, default: 100.0
    t.string   "introduction"
    t.integer  "branch_id"
    t.integer  "available_coupons_count",                                                       default: 0
    t.integer  "used_coupons_count",                                                            default: 0
    t.integer  "max_count_each_user"
  end

  add_index "ddt_abstract_coupon_versions", ["shop_id"], name: "index_ddt_abstract_coupon_versions_on_shop_id", using: :btree

  create_table "ddt_abstract_coupon_versions_branches", id: false, force: true do |t|
    t.integer "abstract_coupon_version_id", null: false
    t.integer "branch_id",                  null: false
  end

  add_index "ddt_abstract_coupon_versions_branches", ["abstract_coupon_version_id", "branch_id"], name: "coupon_appliable_branch_scope_index", unique: true, using: :btree
  add_index "ddt_abstract_coupon_versions_branches", ["abstract_coupon_version_id"], name: "coupon_appliable_branch_scope_coupon_index", using: :btree
  add_index "ddt_abstract_coupon_versions_branches", ["branch_id"], name: "coupon_appliable_branch_scope_branch_id_index", using: :btree

  create_table "ddt_abstract_sources", force: true do |t|
    t.string   "label"
    t.decimal  "amount",     precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ddt_access_tokens", force: true do |t|
    t.integer  "holder_id"
    t.string   "holder_type"
    t.string   "access_token"
    t.datetime "expired_at"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_access_tokens", ["access_token"], name: "index_ddt_access_tokens_on_access_token", length: {"access_token"=>191}, using: :btree

  create_table "ddt_accounts", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.string   "login_id"
    t.string   "name"
    t.string   "phone"
    t.string   "authentication_token"
    t.integer  "user_id"
    t.boolean  "built_in",               default: false
    t.datetime "deleted_at"
    t.string   "notification_email"
    t.string   "last_push_user_id"
    t.string   "last_push_channel_id"
    t.boolean  "accept_term",            default: true
    t.string   "term_version"
  end

  add_index "ddt_accounts", ["authentication_token"], name: "index_ddt_accounts_on_authentication_token", length: {"authentication_token"=>191}, unique: true, using: :btree
  add_index "ddt_accounts", ["confirmation_token"], name: "index_ddt_accounts_on_confirmation_token", length: {"confirmation_token"=>191}, unique: true, using: :btree
  add_index "ddt_accounts", ["email"], name: "index_ddt_accounts_on_email", length: {"email"=>191}, unique: true, using: :btree
  add_index "ddt_accounts", ["login_id", "deleted_at"], name: "index_ddt_accounts_on_login_id_and_deleted_at", length: {"login_id"=>191}, unique: true, using: :btree
  add_index "ddt_accounts", ["reset_password_token"], name: "index_ddt_accounts_on_reset_password_token", length: {"reset_password_token"=>191}, unique: true, using: :btree
  add_index "ddt_accounts", ["shop_id"], name: "index_ddt_accounts_on_shop_id", using: :btree
  add_index "ddt_accounts", ["unlock_token"], name: "index_ddt_accounts_on_unlock_token", length: {"unlock_token"=>191}, unique: true, using: :btree

  create_table "ddt_accounts_categories", id: false, force: true do |t|
    t.integer "account_id"
    t.integer "category_id"
  end

  add_index "ddt_accounts_categories", ["account_id", "category_id"], name: "index_ddt_accounts_categories", using: :btree

  create_table "ddt_accounts_products", id: false, force: true do |t|
    t.integer "account_id"
    t.integer "product_id"
  end

  add_index "ddt_accounts_products", ["account_id"], name: "index_ddt_accounts_products_on_account_id", using: :btree
  add_index "ddt_accounts_products", ["product_id"], name: "index_ddt_accounts_products_on_product_id", using: :btree

  create_table "ddt_accounts_roles", id: false, force: true do |t|
    t.integer "account_id"
    t.integer "role_id"
  end

  add_index "ddt_accounts_roles", ["account_id", "role_id"], name: "index_ddt_accounts_roles_on_account_id_and_role_id", using: :btree

  create_table "ddt_addresses", force: true do |t|
    t.integer  "base_user_id"
    t.text     "content",      limit: 16777215
    t.string   "name"
    t.string   "phone"
    t.boolean  "is_default",                                            default: false
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",                      precision: 9, scale: 6
    t.decimal  "longitude",                     precision: 9, scale: 6
    t.string   "city_name"
  end

  add_index "ddt_addresses", ["base_user_id"], name: "index_ddt_addresses_on_base_user_id", using: :btree

  create_table "ddt_adjustments", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "source_type"
    t.integer  "source_id"
    t.string   "adjustable_type"
    t.integer  "adjustable_id"
    t.integer  "order_id"
    t.string   "label"
    t.decimal  "amount",          precision: 8, scale: 2, default: 0.0
    t.boolean  "eligible"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_adjustments", ["adjustable_type", "adjustable_id"], name: "index_ddt_adjustments_on_adjustable", length: {"adjustable_type"=>191, "adjustable_id"=>nil}, using: :btree
  add_index "ddt_adjustments", ["branch_id"], name: "index_ddt_adjustments_on_branch_id", using: :btree
  add_index "ddt_adjustments", ["order_id"], name: "index_ddt_adjustments_on_order_id", using: :btree
  add_index "ddt_adjustments", ["shop_id"], name: "index_ddt_adjustments_on_shop_id", using: :btree
  add_index "ddt_adjustments", ["source_type", "source_id"], name: "index_ddt_adjustments_on_source_type_and_source_id", length: {"source_type"=>191, "source_id"=>nil}, using: :btree

  create_table "ddt_agent_logs", force: true do |t|
    t.string   "log_type"
    t.integer  "balance_delta"
    t.integer  "agent_id"
    t.text     "description",   limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_agent_logs", ["agent_id"], name: "index_ddt_agent_logs_on_agent_id", using: :btree

  create_table "ddt_agent_materials", force: true do |t|
    t.string   "title"
    t.text     "content",    limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ddt_agent_rels", force: true do |t|
    t.integer  "agent_id"
    t.integer  "agent_zone_id"
    t.datetime "agent_from"
    t.datetime "agent_to"
  end

  create_table "ddt_agent_zones", force: true do |t|
    t.string   "name"
    t.integer  "parent_agent_zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
  end

  add_index "ddt_agent_zones", ["parent_agent_zone_id"], name: "index_ddt_agent_zones_on_parent_agent_zone_id", using: :btree

  create_table "ddt_agents", force: true do |t|
    t.string   "agent_no"
    t.string   "name"
    t.string   "phone"
    t.decimal  "balance",                precision: 8, scale: 2, default: 0.0
    t.string   "brand"
    t.string   "company_name"
    t.string   "email",                                          default: "",            null: false
    t.string   "encrypted_password",                             default: "",            null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                  default: 0,             null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "single_price"
    t.integer  "multiple_price"
    t.datetime "expiration_time"
    t.boolean  "is_oem",                                         default: false
    t.string   "domain"
    t.string   "wechat_introduce_url"
    t.string   "email_address",                                  default: "smtp.qq.com"
    t.string   "email_user_name"
    t.string   "email_password"
  end

  add_index "ddt_agents", ["domain"], name: "index_ddt_agents_on_domain", using: :btree
  add_index "ddt_agents", ["email"], name: "index_ddt_agents_on_email", :length=>{"email"=>191}, unique: true, using: :btree
  add_index "ddt_agents", ["reset_password_token"], name: "index_ddt_agents_on_reset_password_token", :length=>{"reset_password_token"=>191}, unique: true, using: :btree

  create_table "ddt_append_itemable_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.string   "itemable_type"
    t.integer  "itemable_id"
    t.integer  "quantity"
    t.string   "operator_type"
    t.integer  "operator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_append_itemable_records", ["branch_id"], name: "index_ddt_append_itemable_records_on_branch_id", using: :btree
  add_index "ddt_append_itemable_records", ["itemable_type", "itemable_id"], name: "index_ddt_append_itemable_records_on_itemable", length: {"itemable_type"=>191, "itemable_id"=>nil}, using: :btree
  add_index "ddt_append_itemable_records", ["operator_type", "operator_id"], name: "index_ddt_append_itemable_records_on_operator", length: {"operator_type"=>191, "operator_id"=>nil}, using: :btree
  add_index "ddt_append_itemable_records", ["order_id"], name: "index_ddt_append_itemable_records_on_order_id", using: :btree
  add_index "ddt_append_itemable_records", ["shop_id"], name: "index_ddt_append_itemable_records_on_shop_id", using: :btree

  create_table "ddt_arranging_settings", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "mode",       default: "auto_assigned"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_arranging_settings", ["branch_id"], name: "index_ddt_arranging_settings_on_branch_id", using: :btree
  add_index "ddt_arranging_settings", ["shop_id"], name: "index_ddt_arranging_settings_on_shop_id", using: :btree

  create_table "ddt_articles", force: true do |t|
    t.string   "title"
    t.text     "description",  limit: 16777215
    t.string   "pic_url"
    t.text     "url",          limit: 16777215
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "image"
    t.string   "img_url"
    t.string   "link_type"
    t.integer  "position",                      default: 1
    t.text     "introduction", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
  end

  add_index "ddt_articles", ["owner_type", "owner_id"], name: "index_ddt_articles_on_owner_type_and_owner_id", length: {"owner_type"=>191, "owner_id"=>nil}, using: :btree

  create_table "ddt_assets", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "viewable_id"
    t.string   "viewable_type"
    t.string   "type"
    t.string   "attachment"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "file_size"
    t.string   "content_type"
  end

  add_index "ddt_assets", ["branch_id"], name: "index_ddt_assets_on_branch_id", using: :btree
  add_index "ddt_assets", ["shop_id"], name: "index_ddt_assets_on_shop_id", using: :btree
  add_index "ddt_assets", ["type", "viewable_type"], name: "index_ddt_assets_on_type_and_viewable_type", length: {"type"=>191, "viewable_type"=>191}, using: :btree

  create_table "ddt_auto_update_configs", force: true do |t|
    t.integer "shop_id"
    t.integer "branch_id"
    t.integer "owner_id"
    t.string  "owner_type"
    t.string  "column_names"
  end

  add_index "ddt_auto_update_configs", ["branch_id"], name: "index_ddt_auto_update_configs_on_branch_id", using: :btree
  add_index "ddt_auto_update_configs", ["owner_id", "owner_type"], name: "index_ddt_auto_update_configs_on_owner_id_and_owner_type", length: {"owner_id"=>nil, "owner_type"=>191}, using: :btree
  add_index "ddt_auto_update_configs", ["shop_id"], name: "index_ddt_auto_update_configs_on_shop_id", using: :btree

  create_table "ddt_base_coupons", force: true do |t|
    t.integer  "base_user_id"
    t.integer  "shop_id"
    t.string   "coupon_no"
    t.datetime "expires_at"
    t.datetime "applied_at"
    t.integer  "bought_from_order_id"
    t.integer  "applied_to_order_id"
    t.integer  "abstract_coupon_version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "refund_at"
    t.string   "type"
    t.integer  "source_id"
    t.string   "source_type"
  end

  add_index "ddt_base_coupons", ["abstract_coupon_version_id"], name: "index_ddt_base_coupons_on_abstract_coupon_version_id", using: :btree
  add_index "ddt_base_coupons", ["applied_to_order_id"], name: "index_ddt_base_coupons_on_applied_to_order_id", using: :btree
  add_index "ddt_base_coupons", ["base_user_id"], name: "index_ddt_base_coupons_on_base_user_id", using: :btree
  add_index "ddt_base_coupons", ["bought_from_order_id"], name: "index_ddt_base_coupons_on_bought_from_order_id", using: :btree
  add_index "ddt_base_coupons", ["id", "type"], name: "index_ddt_base_coupons_on_id_and_type", length: {"id"=>nil, "type"=>191}, using: :btree
  add_index "ddt_base_coupons", ["shop_id"], name: "index_ddt_base_coupons_on_shop_id", using: :btree
  add_index "ddt_base_coupons", ["source_id", "source_type"], name: "index_ddt_base_coupons_on_source_id_and_source_type", length: {"source_id"=>nil, "source_type"=>191}, using: :btree

  create_table "ddt_base_qr_code_scenes", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.string   "gonghao_open_id"
    t.integer  "scan_times",                            default: 0
    t.integer  "scene_id"
    t.string   "url"
    t.integer  "shop_id"
    t.string   "type"
    t.text     "preferences",          limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "builtin",                               default: false
    t.integer  "qrcode_scaners_count",                  default: 0
  end

  add_index "ddt_base_qr_code_scenes", ["owner_id", "owner_type"], name: "index_ddt_base_qr_code_scenes_on_owner_id_and_owner_type", length: {"owner_id"=>nil, "owner_type"=>191}, using: :btree
  add_index "ddt_base_qr_code_scenes", ["scene_id"], name: "index_ddt_base_qr_code_scenes_on_scene_id", using: :btree
  add_index "ddt_base_qr_code_scenes", ["shop_id"], name: "index_ddt_base_qr_code_scenes_on_shop_id", using: :btree

  create_table "ddt_base_users", force: true do |t|
    t.string   "phone"
    t.integer  "placed_orders_count",                                   default: 0
    t.boolean  "is_blocked",                                            default: false
    t.decimal  "total_amount",                  precision: 8, scale: 2, default: 0.0
    t.string   "type",                                                                       null: false
    t.integer  "shop_id"
    t.integer  "vip_info_id"
    t.decimal  "last_latitude",                 precision: 9, scale: 6, default: 31.223501
    t.decimal  "last_longitude",                precision: 9, scale: 6, default: 121.479949
    t.string   "last_location_label"
    t.datetime "last_location_time"
    t.integer  "following_branches_count",                              default: 0
    t.integer  "unique_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                                                 default: "",         null: false
    t.string   "encrypted_password",                                    default: "",         null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                         default: 0,          null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                                       default: 0,          null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "deleted_at"
    t.integer  "sign_records_count",                                    default: 0
    t.integer  "continuous_sign_count",                                 default: 0
    t.string   "host"
    t.integer  "canceled_order_count",                                  default: 0
    t.integer  "continuous_cancel_order_count",                         default: 0
  end

  add_index "ddt_base_users", ["confirmation_token"], name: "index_ddt_base_users_on_confirmation_token", :length => {"confirmation_token" => 191}, unique: true, using: :btree
  add_index "ddt_base_users", ["reset_password_token"], name: "index_ddt_base_users_on_reset_password_token", :length => {"reset_password_token" => 191}, unique: true, using: :btree
  add_index "ddt_base_users", ["shop_id"], name: "index_ddt_base_users_on_shop_id", using: :btree
  add_index "ddt_base_users", ["unique_user_id"], name: "index_ddt_base_users_on_unique_user_id", using: :btree
  add_index "ddt_base_users", ["unlock_token"], name: "index_ddt_base_users_on_unlock_token", :length => {"unlock_token" => 191}, unique: true, using: :btree
  add_index "ddt_base_users", ["vip_info_id"], name: "index_ddt_base_users_on_vip_info_id", using: :btree

  create_table "ddt_branch_sliders", force: true do |t|
    t.integer  "shop_id"
    t.text     "description"
    t.string   "img"
    t.string   "url"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_branch_sliders", ["shop_id"], name: "index_ddt_branch_sliders_on_shop_id", using: :btree

  create_table "ddt_branch_types", force: true do |t|
    t.string   "name"
    t.integer  "branches_count",         default: 0
    t.integer  "shop_id"
    t.string   "icon",                   default: "fa-globe"
    t.string   "bg_color",               default: "#72c02c"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "order_in_seat_img"
    t.string   "delivery_img"
    t.string   "queue_img"
    t.string   "pay_online_img"
    t.string   "reservation_img"
    t.boolean  "show_order_in_seat_img", default: true
    t.boolean  "show_delivery_img",      default: true
    t.boolean  "show_queue_img",         default: true
    t.boolean  "show_pay_online_img",    default: true
    t.boolean  "show_reservation_img",   default: true
    t.string   "order_in_seat_img_text"
    t.string   "delivery_img_text"
    t.string   "queue_img_text"
    t.string   "pay_online_img_text"
    t.string   "reservation_img_text"
    t.boolean  "show_wifi",              default: true
    t.boolean  "show_parking",           default: true
  end

  add_index "ddt_branch_types", ["shop_id"], name: "index_ddt_branch_types_on_shop_id", using: :btree

  create_table "ddt_branches", force: true do |t|
    t.integer  "shop_id"
    t.string   "name",                    limit: 191
    t.string   "image"
    t.string   "rect_image"
    t.boolean  "is_open"
    t.datetime "expiration_time"
    t.string   "notice"
    t.string   "phone"
    t.string   "address"
    t.decimal  "latitude",                                 precision: 9, scale: 6
    t.decimal  "longitude",                                precision: 9, scale: 6
    t.text     "introduction",            limit: 16777215
    t.string   "charge_method"
    t.string   "product_list_style",                                               default: "thumb"
    t.integer  "branch_type_id"
    t.boolean  "use_delivery_setting",                                             default: true
    t.boolean  "use_reservation_setting",                                          default: true
    t.boolean  "use_eat_in_hall_setting",                                          default: true
    t.datetime "deleted_at"
    t.boolean  "check_stock",                                                      default: true
    t.integer  "position",                                                         default: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_queue_setting",                                                default: true
    t.integer  "placed_orders_count",                                              default: 0
    t.boolean  "use_pay_online_setting",                                           default: true
    t.integer  "comments_count",                                                   default: 0
    t.integer  "rating",                                                           default: 0
    t.boolean  "use_sms_validation",                                               default: false
    t.string   "wechat_no"
    t.string   "qq_no"
    t.boolean  "support_wifi",                                                     default: true
    t.boolean  "support_parking",                                                  default: true
    t.integer  "parking_space_count",                                              default: 10
    t.boolean  "support_invoice",                                                  default: false
    t.boolean  "is_abstract",                                                      default: false
    t.integer  "copy_from_id"
  end

  add_index "ddt_branches", ["branch_type_id"], name: "index_ddt_branches_on_branch_type_id", using: :btree
  add_index "ddt_branches", ["shop_id"], name: "index_ddt_branches_on_shop_id", using: :btree

  create_table "ddt_branches_zones", force: true do |t|
    t.integer "branch_id"
    t.integer "zone_id"
  end

  add_index "ddt_branches_zones", ["branch_id"], name: "index_ddt_branches_zones_on_branch_id", using: :btree
  add_index "ddt_branches_zones", ["zone_id"], name: "index_ddt_branches_zones_on_zone_id", using: :btree

  create_table "ddt_calculators", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "type"
    t.integer  "calculable_id"
    t.string   "calculable_type"
    t.text     "preferences"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_calculators", ["branch_id"], name: "index_ddt_calculators_on_branch_id", using: :btree
  add_index "ddt_calculators", ["calculable_type", "calculable_id"], name: "index_ddt_calculators_on_calculable", using: :btree
  add_index "ddt_calculators", ["id", "type"], name: "index_ddt_calculators_on_id_and_type", using: :btree
  add_index "ddt_calculators", ["shop_id"], name: "index_ddt_calculators_on_shop_id", using: :btree

  create_table "ddt_categories", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "support_delivery",    default: true
    t.boolean  "support_reservation", default: true
    t.boolean  "support_eat_in_hall", default: true
  end

  add_index "ddt_categories", ["branch_id"], name: "index_ddt_categories_on_branch_id", using: :btree
  add_index "ddt_categories", ["shop_id"], name: "index_ddt_categories_on_shop_id", using: :btree

  create_table "ddt_categories_products", id: false, force: true do |t|
    t.integer "product_id"
    t.integer "category_id"
  end

  add_index "ddt_categories_products", ["category_id"], name: "index_ddt_categories_products_on_category_id", using: :btree
  add_index "ddt_categories_products", ["product_id"], name: "index_ddt_categories_products_on_product_id", using: :btree

  create_table "ddt_censor_reports", force: true do |t|
    t.integer  "shop_id"
    t.string   "title"
    t.text     "desc"
    t.integer  "base_user_id"
    t.integer  "auditor_id"
    t.datetime "audited_at"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_censor_reports", ["created_at"], name: "index_ddt_censor_reports_on_created_at", using: :btree
  add_index "ddt_censor_reports", ["shop_id"], name: "index_ddt_censor_reports_on_shop_id", using: :btree

  create_table "ddt_change_table_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "from_table_id"
    t.integer  "to_table_id"
    t.integer  "order_id"
    t.string   "operator_type"
    t.integer  "operator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_change_table_records", ["branch_id"], name: "index_ddt_change_table_records_on_branch_id", using: :btree
  add_index "ddt_change_table_records", ["from_table_id"], name: "index_ddt_change_table_records_on_from_table_id", using: :btree
  add_index "ddt_change_table_records", ["operator_type", "operator_id"], name: "index_change_table_records_on_operator", length: {"operator_type"=>191, "operator_id"=>nil}, using: :btree
  add_index "ddt_change_table_records", ["order_id"], name: "index_ddt_change_table_records_on_order_id", using: :btree
  add_index "ddt_change_table_records", ["shop_id"], name: "index_ddt_change_table_records_on_shop_id", using: :btree
  add_index "ddt_change_table_records", ["to_table_id"], name: "index_ddt_change_table_records_on_to_table_id", using: :btree

  create_table "ddt_combo_items", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "combo_id"
    t.string   "name"
    t.integer  "select_count", default: 1
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_combo_items", ["branch_id"], name: "index_ddt_combo_items_on_branch_id", using: :btree
  add_index "ddt_combo_items", ["combo_id"], name: "index_ddt_combo_items_on_combo_id", using: :btree
  add_index "ddt_combo_items", ["shop_id"], name: "index_ddt_combo_items_on_shop_id", using: :btree

  create_table "ddt_combo_items_variants", force: true do |t|
    t.integer "combo_item_id"
    t.integer "variant_id"
  end

  add_index "ddt_combo_items_variants", ["combo_item_id"], name: "index_ddt_combo_items_variants_on_combo_item_id", using: :btree
  add_index "ddt_combo_items_variants", ["variant_id"], name: "index_ddt_combo_items_variants_on_variant_id", using: :btree

  create_table "ddt_combo_package_items", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "combo_package_id"
    t.integer  "variant_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "combo_item_id"
  end

  add_index "ddt_combo_package_items", ["branch_id"], name: "index_ddt_combo_package_items_on_branch_id", using: :btree
  add_index "ddt_combo_package_items", ["combo_item_id"], name: "index_ddt_combo_package_items_on_combo_item_id", using: :btree
  add_index "ddt_combo_package_items", ["combo_package_id"], name: "index_ddt_combo_package_items_on_combo_package_id", using: :btree
  add_index "ddt_combo_package_items", ["shop_id"], name: "index_ddt_combo_package_items_on_shop_id", using: :btree
  add_index "ddt_combo_package_items", ["variant_id"], name: "index_ddt_combo_package_items_on_variant_id", using: :btree

  create_table "ddt_combo_packages", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.integer  "combo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_combo_packages", ["branch_id"], name: "index_ddt_combo_packages_on_branch_id", using: :btree
  add_index "ddt_combo_packages", ["combo_id"], name: "index_ddt_combo_packages_on_combo_id", using: :btree
  add_index "ddt_combo_packages", ["order_id"], name: "index_ddt_combo_packages_on_order_id", using: :btree
  add_index "ddt_combo_packages", ["shop_id"], name: "index_ddt_combo_packages_on_shop_id", using: :btree

  create_table "ddt_combos", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "name"
    t.text     "description"
    t.string   "keywords"
    t.string   "unit_name",                                   default: "份"
    t.integer  "position"
    t.boolean  "support_delivery",                            default: true
    t.boolean  "support_reservation",                         default: true
    t.boolean  "support_eat_in_hall",                         default: true
    t.boolean  "sale_on_monday",                              default: true
    t.boolean  "sale_on_tuesday",                             default: true
    t.boolean  "sale_on_wednesday",                           default: true
    t.boolean  "sale_on_thursday",                            default: true
    t.boolean  "sale_on_friday",                              default: true
    t.boolean  "sale_on_saturday",                            default: true
    t.boolean  "sale_on_sunday",                              default: true
    t.datetime "availabled_at"
    t.string   "sku"
    t.decimal  "price",               precision: 8, scale: 2
    t.decimal  "vip_price",           precision: 8, scale: 2
    t.decimal  "cost_price",          precision: 8, scale: 2
    t.integer  "stock_quantity",                              default: 100
    t.integer  "sale_quantity",                               default: 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "promotionable",                               default: true
  end

  add_index "ddt_combos", ["branch_id"], name: "index_ddt_combos_on_branch_id", using: :btree
  add_index "ddt_combos", ["shop_id"], name: "index_ddt_combos_on_shop_id", using: :btree

  create_table "ddt_combos_promotion_rules", id: false, force: true do |t|
    t.integer "combo_id"
    t.integer "promotion_rule_id"
  end

  add_index "ddt_combos_promotion_rules", ["combo_id"], name: "index_ddt_combos_promotion_rules_on_combo_id", using: :btree
  add_index "ddt_combos_promotion_rules", ["promotion_rule_id"], name: "index_ddt_combos_promotion_rules_on_promotion_rule_id", using: :btree

  create_table "ddt_comments", force: true do |t|
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.string   "content"
    t.integer  "rating"
    t.string   "state",            default: "pending"
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.string   "owner_type"
    t.integer  "owner_id"
  end

  add_index "ddt_comments", ["branch_id"], name: "index_ddt_comments_on_branch_id", using: :btree
  add_index "ddt_comments", ["shop_id"], name: "index_ddt_comments_on_shop_id", using: :btree

  create_table "ddt_coupon_photos", force: true do |t|
    t.string   "image"
    t.integer  "size"
    t.integer  "shop_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_coupon_photos", ["shop_id"], name: "index_ddt_coupon_photos_on_shop_id", using: :btree

  create_table "ddt_coupon_usage_instructions", force: true do |t|
    t.integer  "abstract_coupon_version_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ddt_custom_weixin_infos", force: true do |t|
    t.integer  "shop_id"
    t.text     "preferences"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "layout_type",         default: "fashion"
    t.string   "background_image"
    t.string   "branch_index_layout", default: "list"
  end

  add_index "ddt_custom_weixin_infos", ["shop_id"], name: "index_ddt_custom_weixin_infos_on_shop_id", using: :btree

  create_table "ddt_d_files", force: true do |t|
    t.string   "file_name"
    t.string   "file_path"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ddt_deductions", force: true do |t|
    t.integer  "shop_id"
    t.integer  "order_id"
    t.integer  "wallet_id"
    t.string   "type"
    t.integer  "credits"
    t.decimal  "amount",     precision: 8, scale: 2
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_deductions", ["order_id"], name: "index_ddt_deductions_on_order_id", using: :btree
  add_index "ddt_deductions", ["shop_id"], name: "index_ddt_deductions_on_shop_id", using: :btree
  add_index "ddt_deductions", ["wallet_id"], name: "index_ddt_deductions_on_wallet_id", using: :btree

  create_table "ddt_delivery_fee_settings", force: true do |t|
    t.string   "charge_by",                             default: "zone"
    t.decimal  "per_unit_cost", precision: 8, scale: 2, default: 0.0
    t.integer  "unit",                                  default: 1
    t.integer  "branch_id"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_delivery_fee_settings", ["branch_id"], name: "index_ddt_delivery_fee_settings_on_branch_id", using: :btree
  add_index "ddt_delivery_fee_settings", ["shop_id"], name: "index_ddt_delivery_fee_settings_on_shop_id", using: :btree

  create_table "ddt_delivery_modules", force: true do |t|
    t.integer  "shop_id"
    t.datetime "expired_at"
    t.boolean  "enable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_delivery_modules", ["shop_id"], name: "index_ddt_delivery_modules_on_shop_id", using: :btree

  create_table "ddt_delivery_ranges", force: true do |t|
    t.integer  "start_at"
    t.integer  "end_at"
    t.decimal  "cost",       precision: 8, scale: 2, default: 0.0
    t.integer  "branch_id"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_delivery_ranges", ["branch_id"], name: "index_ddt_delivery_ranges_on_branch_id", using: :btree
  add_index "ddt_delivery_ranges", ["shop_id"], name: "index_ddt_delivery_ranges_on_shop_id", using: :btree

  create_table "ddt_delivery_settings", force: true do |t|
    t.integer  "branch_id"
    t.decimal  "support_delivery_if_amount_gt",           precision: 8, scale: 2, default: 10.0
    t.decimal  "charge_delivery_fee_if_amount_lt",        precision: 8, scale: 2, default: 100.0
    t.integer  "receive_delivery_order_within_days",                              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_fixed_delivery_time",                                         default: false
    t.integer  "delivery_need_minutes",                                           default: 20
    t.decimal  "delivery_radius",                         precision: 6, scale: 2, default: 3.0
    t.decimal  "min_delivery_fee",                        precision: 8, scale: 2, default: 0.0
    t.boolean  "support_order_if_not_in_delivery_radius",                         default: true
    t.string   "charge_by",                                                       default: "zone"
    t.decimal  "per_unit_cost",                           precision: 8, scale: 2, default: 0.0
    t.integer  "unit",                                                            default: 1
  end

  add_index "ddt_delivery_settings", ["branch_id"], name: "index_ddt_delivery_settings_on_branch_id", using: :btree

  create_table "ddt_delivery_times", force: true do |t|
    t.time     "start_time"
    t.time     "end_time"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delivery_setting_id"
    t.time     "cut_off_time"
    t.boolean  "enable_limit",        default: false
  end

  add_index "ddt_delivery_times", ["delivery_setting_id"], name: "index_ddt_delivery_times_on_delivery_setting_id", using: :btree

  create_table "ddt_delivery_zones", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.decimal  "cost",       precision: 8, scale: 2, default: 0.0
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zone_name"
  end

  add_index "ddt_delivery_zones", ["branch_id"], name: "index_ddt_delivery_zones_on_branch_id", using: :btree
  add_index "ddt_delivery_zones", ["shop_id"], name: "index_ddt_delivery_zones_on_shop_id", using: :btree

  create_table "ddt_diancaibao_modules", force: true do |t|
    t.integer  "shop_id"
    t.datetime "expired_at"
    t.boolean  "enable",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_diancaibao_modules", ["shop_id"], name: "index_ddt_diancaibao_modules_on_shop_id", using: :btree

  create_table "ddt_eat_in_hall_modules", force: true do |t|
    t.integer  "shop_id"
    t.datetime "expired_at"
    t.boolean  "enable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_eat_in_hall_modules", ["shop_id"], name: "index_ddt_eat_in_hall_modules_on_shop_id", using: :btree

  create_table "ddt_eat_in_hall_settings", force: true do |t|
    t.integer  "branch_id"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_eat_in_hall_settings", ["branch_id"], name: "index_ddt_eat_in_hall_settings_on_branch_id", using: :btree
  add_index "ddt_eat_in_hall_settings", ["shop_id"], name: "index_ddt_eat_in_hall_settings_on_shop_id", using: :btree

  create_table "ddt_email_settings", force: true do |t|
    t.integer  "shop_id"
    t.string   "address",    default: "smtp.qq.com"
    t.string   "user_name"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_email_settings", ["shop_id"], name: "index_ddt_email_settings_on_shop_id", using: :btree

  create_table "ddt_events", force: true do |t|
    t.string   "event_type"
    t.string   "event_key"
    t.boolean  "is_system_keyword"
    t.string   "system_keyword"
    t.integer  "material_id"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_events", ["event_key"], name: "index ddt_events on event_key", length: {"event_key"=>191}, using: :btree
  add_index "ddt_events", ["event_type"], name: "index ddt_events on event_type", length: {"event_type"=>191}, using: :btree
  add_index "ddt_events", ["material_id"], name: "index_ddt_events_on_material_id", using: :btree
  add_index "ddt_events", ["shop_id"], name: "index_ddt_events_on_shop_id", using: :btree

  create_table "ddt_exchange_codes", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "exchangeable_id"
    t.string   "exchangeable_type"
    t.string   "state"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "exchanged_at"
  end

  add_index "ddt_exchange_codes", ["branch_id"], name: "index_ddt_exchange_codes_on_branch_id", using: :btree
  add_index "ddt_exchange_codes", ["exchangeable_id", "exchangeable_type"], name: "index_exchange_codes_on_exchangeable", length: {"exchangeable_id"=>nil, "exchangeable_type"=>191}, using: :btree
  add_index "ddt_exchange_codes", ["shop_id"], name: "index_ddt_exchange_codes_on_shop_id", using: :btree

  create_table "ddt_form_contents", force: true do |t|
    t.integer  "form_element_id"
    t.integer  "order_id"
    t.string   "label"
    t.string   "content"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_form_contents", ["form_element_id"], name: "index_ddt_form_contents_on_form_element_id", using: :btree
  add_index "ddt_form_contents", ["order_id"], name: "index_ddt_form_contents_on_order_id", using: :btree

  create_table "ddt_form_elements", force: true do |t|
    t.string   "type"
    t.string   "statement"
    t.integer  "sequence"
    t.integer  "form_element_id"
    t.integer  "branch_id"
    t.integer  "shop_id"
    t.boolean  "need"
    t.string   "placeholder"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "support_delivery"
    t.boolean  "support_eat_in_hall"
    t.boolean  "support_reservation"
  end

  add_index "ddt_form_elements", ["branch_id"], name: "index_ddt_form_elements_on_branch_id", using: :btree
  add_index "ddt_form_elements", ["form_element_id"], name: "index_ddt_form_elements_on_form_element_id", using: :btree
  add_index "ddt_form_elements", ["shop_id"], name: "index_ddt_form_elements_on_shop_id", using: :btree

  create_table "ddt_groupon_line_items", force: true do |t|
    t.integer  "groupon_version_id"
    t.string   "name"
    t.integer  "quantity"
    t.string   "unit_name"
    t.integer  "variant_id"
    t.decimal  "price",              precision: 8, scale: 2
    t.decimal  "groupon_price",      precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_groupon_line_items", ["groupon_version_id"], name: "index_ddt_groupon_line_items_on_groupon_version_id", using: :btree
  add_index "ddt_groupon_line_items", ["variant_id"], name: "index_ddt_groupon_line_items_on_variant_id", using: :btree

  create_table "ddt_groupon_modules", force: true do |t|
    t.integer  "shop_id"
    t.datetime "expired_at"
    t.boolean  "enable",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_groupon_modules", ["shop_id"], name: "index_ddt_groupon_modules_on_shop_id", using: :btree

  create_table "ddt_guest_queue_dequeued_events", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "queue_setting_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_guest_queue_id"
  end

  add_index "ddt_guest_queue_dequeued_events", ["branch_id"], name: "index_ddt_guest_queue_dequeued_events_on_branch_id", using: :btree
  add_index "ddt_guest_queue_dequeued_events", ["queue_setting_id"], name: "index_ddt_guest_queue_dequeued_events_on_queue_setting_id", using: :btree
  add_index "ddt_guest_queue_dequeued_events", ["shop_id"], name: "index_ddt_guest_queue_dequeued_events_on_shop_id", using: :btree
  add_index "ddt_guest_queue_dequeued_events", ["source_guest_queue_id"], name: "guest_queue_dequeued_event_source_guest_id", using: :btree

  create_table "ddt_guest_queue_notifications", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "queue_setting_id"
    t.integer  "guest_queue_dequeued_event_id"
    t.integer  "guest_queue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_guest_queue_notifications", ["branch_id"], name: "index_ddt_guest_queue_notifications_on_branch_id", using: :btree
  add_index "ddt_guest_queue_notifications", ["guest_queue_dequeued_event_id"], name: "index_guest_queue_notifications_on_event", using: :btree
  add_index "ddt_guest_queue_notifications", ["queue_setting_id"], name: "index_ddt_guest_queue_notifications_on_queue_setting_id", using: :btree
  add_index "ddt_guest_queue_notifications", ["shop_id"], name: "index_ddt_guest_queue_notifications_on_shop_id", using: :btree

  create_table "ddt_guest_queues", force: true do |t|
    t.string   "guest_no"
    t.integer  "branch_id"
    t.integer  "shop_id"
    t.string   "workflow_state",   default: "queueing"
    t.boolean  "is_notified",      default: false
    t.integer  "base_user_id"
    t.string   "phone"
    t.integer  "guest_num"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "queue_setting_id"
    t.string   "track_from"
  end

  add_index "ddt_guest_queues", ["base_user_id"], name: "index_ddt_guest_queues_on_base_user_id", using: :btree
  add_index "ddt_guest_queues", ["branch_id"], name: "index_ddt_guest_queues_on_branch_id", using: :btree
  add_index "ddt_guest_queues", ["queue_setting_id"], name: "index_ddt_guest_queues_on_queue_setting_id", using: :btree
  add_index "ddt_guest_queues", ["shop_id"], name: "index_ddt_guest_queues_on_shop_id", using: :btree

  create_table "ddt_home_hot_links", force: true do |t|
    t.integer  "shop_id"
    t.integer  "custom_weixin_info_id"
    t.string   "label"
    t.string   "icon"
    t.string   "image"
    t.string   "icon_background_color"
    t.string   "link"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shop_type"
  end

  add_index "ddt_home_hot_links", ["custom_weixin_info_id"], name: "index_ddt_home_hot_links_on_custom_weixin_info_id", using: :btree
  add_index "ddt_home_hot_links", ["shop_id"], name: "index_ddt_home_hot_links_on_shop_id", using: :btree

  create_table "ddt_home_usable_links", force: true do |t|
    t.integer  "shop_id"
    t.integer  "custom_weixin_info_id"
    t.string   "title"
    t.string   "keywords"
    t.string   "image"
    t.string   "link"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_home_usable_links", ["custom_weixin_info_id"], name: "index_ddt_home_usable_links_on_custom_weixin_info_id", using: :btree
  add_index "ddt_home_usable_links", ["shop_id"], name: "index_ddt_home_usable_links_on_shop_id", using: :btree

  create_table "ddt_invitation_order_guests", force: true do |t|
    t.integer "order_id"
    t.integer "guest_id"
    t.boolean "agree",    default: true
  end

  add_index "ddt_invitation_order_guests", ["guest_id"], name: "index_ddt_invitation_order_guests_on_guest_id", using: :btree
  add_index "ddt_invitation_order_guests", ["order_id"], name: "index_ddt_invitation_order_guests_on_order_id", using: :btree

  create_table "ddt_invoices", force: true do |t|
    t.integer  "order_id"
    t.string   "invoice_type"
    t.string   "payer",        default: "personal"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_invoices", ["order_id"], name: "index_ddt_invoices_on_order_id", using: :btree

  create_table "ddt_jokes", force: true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ddt_js_error_counts", force: true do |t|
    t.string   "ip"
    t.integer  "js_error_id"
    t.integer  "count",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_js_error_counts", ["count"], name: "index_ddt_js_error_counts_on_count", using: :btree
  add_index "ddt_js_error_counts", ["js_error_id"], name: "index_ddt_js_error_counts_on_js_error_id", using: :btree

  create_table "ddt_js_errors", force: true do |t|
    t.string   "url"
    t.string   "agent"
    t.text     "error_message", limit: 16777215
    t.text     "stack_trace",   limit: 16777215
    t.text     "cause",         limit: 16777215
    t.integer  "count",                          default: 1
    t.string   "digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_js_errors", ["count"], name: "index_ddt_js_errors_on_count", using: :btree
  add_index "ddt_js_errors", ["created_at"], name: "index_ddt_js_errors_on_created_at", using: :btree
  add_index "ddt_js_errors", ["digest"], name: "index_ddt_js_errors_on_digest", length: {"digest"=>191}, using: :btree
  add_index "ddt_js_errors", ["updated_at"], name: "index_ddt_js_errors_on_updated_at", using: :btree
  add_index "ddt_js_errors", ["url"], name: "index_ddt_js_errors_on_url", length: {"url"=>191}, using: :btree

  create_table "ddt_last_import_product_errors", force: true do |t|
    t.text     "error_csv"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_last_import_product_errors", ["branch_id"], name: "index_ddt_last_import_product_errors_on_branch_id", using: :btree

  create_table "ddt_line_item_trace_points", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.integer  "line_item_id"
    t.integer  "order_change_log_id"
    t.string   "itemable_type"
    t.integer  "itemable_id"
    t.string   "name"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_line_item_trace_points", ["branch_id"], name: "index_ddt_line_item_trace_points_on_branch_id", using: :btree
  add_index "ddt_line_item_trace_points", ["itemable_type", "itemable_id"], name: "index_line_item_trace_points_on_itemable", length: {"itemable_type"=>191, "itemable_id"=>nil}, using: :btree
  add_index "ddt_line_item_trace_points", ["line_item_id"], name: "index_ddt_line_item_trace_points_on_line_item_id", using: :btree
  add_index "ddt_line_item_trace_points", ["order_change_log_id"], name: "index_ddt_line_item_trace_points_on_order_change_log_id", using: :btree
  add_index "ddt_line_item_trace_points", ["order_id"], name: "index_ddt_line_item_trace_points_on_order_id", using: :btree
  add_index "ddt_line_item_trace_points", ["shop_id"], name: "index_ddt_line_item_trace_points_on_shop_id", using: :btree

  create_table "ddt_line_items", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.integer  "quantity"
    t.decimal  "price",            precision: 8, scale: 2
    t.decimal  "cost_price",       precision: 8, scale: 2
    t.decimal  "adjustment_total", precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "itemable_type"
    t.integer  "itemable_id"
  end

  add_index "ddt_line_items", ["branch_id"], name: "index_ddt_line_items_on_branch_id", using: :btree
  add_index "ddt_line_items", ["itemable_type", "itemable_id"], name: "index_ddt_line_items_on_itemable_type_and_itemable_id", length: {"itemable_type"=>191, "itemable_id"=>nil}, using: :btree
  add_index "ddt_line_items", ["order_id"], name: "index_ddt_line_items_on_order_id", using: :btree
  add_index "ddt_line_items", ["shop_id"], name: "index_ddt_line_items_on_shop_id", using: :btree

  create_table "ddt_lisences", force: true do |t|
    t.string   "lisence_no"
    t.decimal  "price",                           precision: 8, scale: 2
    t.boolean  "is_used"
    t.datetime "used_time"
    t.integer  "increment_days"
    t.string   "lisence_type"
    t.integer  "shop_id"
    t.integer  "agent_id"
    t.text     "note",           limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_lisences", ["agent_id"], name: "index_ddt_lisences_on_agent_id", using: :btree
  add_index "ddt_lisences", ["shop_id"], name: "index_ddt_lisences_on_shop_id", using: :btree

  create_table "ddt_locations", force: true do |t|
    t.integer  "owner_id"
    t.decimal  "longitude",  precision: 9, scale: 6
    t.decimal  "latitude",   precision: 9, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_type"
  end

  add_index "ddt_locations", ["owner_id"], name: "index_ddt_locations_on_owner_id", using: :btree

  create_table "ddt_manageships", force: true do |t|
    t.integer  "account_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_manageships", ["account_id"], name: "index_ddt_manageships_on_account_id", using: :btree
  add_index "ddt_manageships", ["branch_id"], name: "index_ddt_manageships_on_branch_id", using: :btree

  create_table "ddt_materials", force: true do |t|
    t.string   "msg_type"
    t.string   "material_name"
    t.text     "content",       limit: 16777215
    t.string   "title"
    t.text     "description",   limit: 16777215
    t.string   "music_url"
    t.string   "hq_music_url"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_materials", ["shop_id"], name: "index_ddt_materials_on_shop_id", using: :btree

  create_table "ddt_merchant_applies", force: true do |t|
    t.integer  "shop_id"
    t.integer  "user_id"
    t.string   "phone"
    t.text     "note"
    t.string   "workflow_state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_merchant_applies", ["shop_id"], name: "index_ddt_merchant_applies_on_shop_id", using: :btree
  add_index "ddt_merchant_applies", ["user_id"], name: "index_ddt_merchant_applies_on_user_id", using: :btree

  create_table "ddt_merge_table_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "from_table_id"
    t.integer  "to_table_id"
    t.integer  "from_order_id"
    t.integer  "to_order_id"
    t.string   "operator_type"
    t.integer  "operator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_merge_table_records", ["branch_id"], name: "index_ddt_merge_table_records_on_branch_id", using: :btree
  add_index "ddt_merge_table_records", ["from_order_id"], name: "index_ddt_merge_table_records_on_from_order_id", using: :btree
  add_index "ddt_merge_table_records", ["from_table_id"], name: "index_ddt_merge_table_records_on_from_table_id", using: :btree
  add_index "ddt_merge_table_records", ["operator_type", "operator_id"], name: "index_merge_table_records_on_operator", length: {"operator_type"=>191, "operator_id"=>nil}, using: :btree
  add_index "ddt_merge_table_records", ["shop_id"], name: "index_ddt_merge_table_records_on_shop_id", using: :btree
  add_index "ddt_merge_table_records", ["to_order_id"], name: "index_ddt_merge_table_records_on_to_order_id", using: :btree
  add_index "ddt_merge_table_records", ["to_table_id"], name: "index_ddt_merge_table_records_on_to_table_id", using: :btree

  create_table "ddt_message_receptions", force: true do |t|
    t.integer  "shop_id"
    t.string   "msg_id"
    t.string   "msg_type"
    t.string   "to_user_name"
    t.string   "from_user_name"
    t.integer  "create_time"
    t.text     "content"
    t.integer  "media_id"
    t.string   "pic_url"
    t.string   "voice_format"
    t.integer  "thumb_media_id"
    t.float    "location_x"
    t.float    "location_y"
    t.integer  "scale"
    t.string   "label"
    t.string   "title"
    t.string   "description"
    t.string   "url"
    t.string   "event"
    t.text     "event_key"
    t.string   "ticket"
    t.decimal  "longitude",      precision: 9, scale: 6
    t.decimal  "latitude",       precision: 9, scale: 6
    t.float    "precision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_message_receptions", ["shop_id"], name: "index_ddt_message_receptions_on_shop_id", using: :btree

  create_table "ddt_message_response_items", force: true do |t|
    t.integer  "shop_id"
    t.integer  "message_response_id"
    t.string   "title"
    t.text     "description",         limit: 16777215
    t.string   "pic_url"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_message_response_items", ["message_response_id"], name: "index_ddt_message_response_items_on_message_response_id", using: :btree
  add_index "ddt_message_response_items", ["shop_id"], name: "index_ddt_message_response_items_on_shop_id", using: :btree

  create_table "ddt_message_responses", force: true do |t|
    t.integer  "shop_id"
    t.integer  "message_reception_id"
    t.string   "msg_type"
    t.string   "to_user_name"
    t.string   "from_user_name"
    t.integer  "create_time"
    t.text     "content",              limit: 16777215
    t.integer  "media_id"
    t.string   "title"
    t.text     "description",          limit: 16777215
    t.string   "music_url"
    t.string   "hq_music_url"
    t.string   "thumb_media_id"
    t.integer  "article_count",                         default: 0
    t.string   "pic_url"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_message_responses", ["message_reception_id"], name: "index_ddt_message_responses_on_message_reception_id", using: :btree
  add_index "ddt_message_responses", ["shop_id"], name: "index_ddt_message_responses_on_shop_id", using: :btree

  create_table "ddt_notification_actions", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "notification_id"
    t.string   "type"
    t.string   "state"
    t.text     "content",         limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_notification_actions", ["branch_id"], name: "index_ddt_notification_actions_on_branch_id", using: :btree
  add_index "ddt_notification_actions", ["notification_id"], name: "index_ddt_notification_actions_on_notification_id", using: :btree
  add_index "ddt_notification_actions", ["shop_id"], name: "index_ddt_notification_actions_on_shop_id", using: :btree

  create_table "ddt_notification_events", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "table_id"
    t.integer  "base_coupon_id"
    t.integer  "order_change_log_id"
    t.integer  "change_table_record_id"
    t.integer  "merge_table_record_id"
    t.integer  "shipment_id"
    t.integer  "guest_queue_id"
    t.text     "preferences"
    t.integer  "account_id"
  end

  add_index "ddt_notification_events", ["account_id"], name: "index_ddt_notification_events_on_account_id", using: :btree
  add_index "ddt_notification_events", ["base_coupon_id"], name: "index_ddt_notification_events_on_base_coupon_id", using: :btree
  add_index "ddt_notification_events", ["branch_id"], name: "index_ddt_notification_events_on_branch_id", using: :btree
  add_index "ddt_notification_events", ["change_table_record_id"], name: "index_ddt_notification_events_on_change_table_record_id", using: :btree
  add_index "ddt_notification_events", ["guest_queue_id"], name: "index_ddt_notification_events_on_guest_queue_id", using: :btree
  add_index "ddt_notification_events", ["id", "type"], name: "index_ddt_notification_events_on_id_and_type", length: {"id"=>nil, "type"=>191}, using: :btree
  add_index "ddt_notification_events", ["merge_table_record_id"], name: "index_ddt_notification_events_on_merge_table_record_id", using: :btree
  add_index "ddt_notification_events", ["order_change_log_id"], name: "index_ddt_notification_events_on_order_change_log_id", using: :btree
  add_index "ddt_notification_events", ["order_id"], name: "index_ddt_notification_events_on_order_id", using: :btree
  add_index "ddt_notification_events", ["shipment_id"], name: "index_ddt_notification_events_on_shipment_id", using: :btree
  add_index "ddt_notification_events", ["shop_id"], name: "index_ddt_notification_events_on_shop_id", using: :btree
  add_index "ddt_notification_events", ["table_id"], name: "index_ddt_notification_events_on_table_id", using: :btree

  create_table "ddt_notification_events_accounts", id: false, force: true do |t|
    t.integer "notification_event_id"
    t.integer "account_id"
  end

  add_index "ddt_notification_events_accounts", ["notification_event_id", "account_id"], name: "index_for_notification_events_accounts", using: :btree

  create_table "ddt_notification_events_base_users", id: false, force: true do |t|
    t.integer "notification_event_id"
    t.integer "base_user_id"
  end

  add_index "ddt_notification_events_base_users", ["notification_event_id", "base_user_id"], name: "index_for_notification_events_base_users", using: :btree

  create_table "ddt_notification_events_printers", id: false, force: true do |t|
    t.integer "notification_event_id"
    t.integer "printer_id"
  end

  add_index "ddt_notification_events_printers", ["notification_event_id", "printer_id"], name: "index_for_notification_events_printers", using: :btree

  create_table "ddt_notifications", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "notification_target_type"
    t.integer  "notification_target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notification_event_id"
  end

  add_index "ddt_notifications", ["branch_id"], name: "index_ddt_notifications_on_branch_id", using: :btree
  add_index "ddt_notifications", ["notification_event_id"], name: "index_ddt_notifications_on_notification_event_id", using: :btree
  add_index "ddt_notifications", ["notification_target_type", "notification_target_id"], name: "index_ddt_notifications_on_notification_target", length: {"notification_target_type"=>191, "notification_target_id"=>nil}, using: :btree
  add_index "ddt_notifications", ["shop_id"], name: "index_ddt_notifications_on_shop_id", using: :btree

  create_table "ddt_one_pages", force: true do |t|
    t.integer  "shop_id"
    t.string   "image"
    t.string   "abstract"
    t.integer  "position"
    t.string   "alignment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_one_pages", ["shop_id"], name: "index_ddt_one_pages_on_shop_id", using: :btree

  create_table "ddt_option_types", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "name"
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_option_types", ["branch_id"], name: "index_ddt_option_types_on_branch_id", using: :btree
  add_index "ddt_option_types", ["shop_id"], name: "index_ddt_option_types_on_shop_id", using: :btree

  create_table "ddt_option_values", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "option_type_id"
    t.string   "name"
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_option_values", ["branch_id"], name: "index_ddt_option_values_on_branch_id", using: :btree
  add_index "ddt_option_values", ["option_type_id"], name: "index_ddt_option_values_on_option_type_id", using: :btree
  add_index "ddt_option_values", ["shop_id"], name: "index_ddt_option_values_on_shop_id", using: :btree

  create_table "ddt_option_values_variants", id: false, force: true do |t|
    t.integer "variant_id"
    t.integer "option_value_id"
  end

  add_index "ddt_option_values_variants", ["option_value_id"], name: "index_ddt_option_values_variants_on_option_value_id", using: :btree
  add_index "ddt_option_values_variants", ["variant_id"], name: "index_ddt_option_values_variants_on_variant_id", using: :btree

  create_table "ddt_order_change_logs", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.string   "operator_type"
    t.integer  "operator_id"
    t.string   "type"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_order_change_logs", ["branch_id"], name: "index_ddt_order_change_logs_on_branch_id", using: :btree
  add_index "ddt_order_change_logs", ["operator_type", "operator_id"], name: "index_order_change_logs_on_operator", length: {"operator_type"=>191, "operator_id"=>nil}, using: :btree
  add_index "ddt_order_change_logs", ["order_id"], name: "index_ddt_order_change_logs_on_order_id", using: :btree
  add_index "ddt_order_change_logs", ["shop_id"], name: "index_ddt_order_change_logs_on_shop_id", using: :btree

  create_table "ddt_orders", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "base_user_id"
    t.integer  "waiter_id"
    t.string   "type"
    t.string   "number",           limit: 191
    t.boolean  "is_proxy",                                             default: false
    t.string   "state"
    t.integer  "item_count"
    t.text     "note"
    t.decimal  "item_total",                   precision: 8, scale: 2, default: 0.0
    t.decimal  "adjustment_total",             precision: 8, scale: 2, default: 0.0
    t.decimal  "shipment_total",               precision: 8, scale: 2, default: 0.0
    t.decimal  "total",                        precision: 8, scale: 2, default: 0.0
    t.decimal  "credits_total",                precision: 8, scale: 2, default: 0.0
    t.decimal  "wallet_total",                 precision: 8, scale: 2, default: 0.0
    t.decimal  "payment_total",                precision: 8, scale: 2, default: 0.0
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_state"
    t.string   "shipment_state"
    t.datetime "placed_at"
    t.string   "prepayment_type"
    t.integer  "table_id"
    t.string   "pay_method"
    t.decimal  "latitude",                     precision: 9, scale: 6
    t.decimal  "longitude",                    precision: 9, scale: 6
    t.string   "location_label"
    t.decimal  "tax_total",                    precision: 8, scale: 2, default: 0.0
    t.integer  "account_id"
    t.integer  "vip_info_id"
    t.string   "track_from"
  end

  add_index "ddt_orders", ["account_id"], name: "index_ddt_orders_on_account_id", using: :btree
  add_index "ddt_orders", ["base_user_id"], name: "index_ddt_orders_on_base_user_id", using: :btree
  add_index "ddt_orders", ["branch_id"], name: "index_ddt_orders_on_branch_id", using: :btree
  add_index "ddt_orders", ["number"], name: "index_ddt_orders_on_number", unique: true, using: :btree
  add_index "ddt_orders", ["shop_id"], name: "index_ddt_orders_on_shop_id", using: :btree
  add_index "ddt_orders", ["table_id"], name: "index_ddt_orders_on_table_id", using: :btree
  add_index "ddt_orders", ["type", "id"], name: "index_ddt_orders_on_type_and_id", length: {"type"=>191, "id"=>nil}, using: :btree
  add_index "ddt_orders", ["vip_info_id"], name: "index_ddt_orders_on_vip_info_id", using: :btree
  add_index "ddt_orders", ["waiter_id"], name: "index_ddt_orders_on_waiter_id", using: :btree

  create_table "ddt_pay_method_settings", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "type"
    t.boolean  "can_credits_deduction", default: true
    t.boolean  "can_card_deduction",    default: true
    t.boolean  "can_pay_on_face",       default: true
    t.boolean  "can_pay_on_arrive",     default: true
    t.boolean  "can_pay_on_receive",    default: true
    t.boolean  "can_alipay",            default: true
    t.boolean  "can_wechatpay",         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_baidupay",          default: true
  end

  add_index "ddt_pay_method_settings", ["branch_id"], name: "index_ddt_pay_method_settings_on_branch_id", using: :btree
  add_index "ddt_pay_method_settings", ["shop_id"], name: "index_ddt_pay_method_settings_on_shop_id", using: :btree

  create_table "ddt_payment_methods", force: true do |t|
    t.integer  "shop_id"
    t.string   "type"
    t.string   "name"
    t.string   "description"
    t.boolean  "active"
    t.text     "preferences", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_payment_methods", ["shop_id"], name: "index_ddt_payment_methods_on_shop_id", using: :btree

  create_table "ddt_payments", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.decimal  "amount",                             precision: 8, scale: 2
    t.string   "workflow_state"
    t.integer  "payment_method_id"
    t.string   "partner_id"
    t.string   "out_trade_no"
    t.text     "preferences",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_payments", ["branch_id"], name: "index_ddt_payments_on_branch_id", using: :btree
  add_index "ddt_payments", ["order_id"], name: "index_ddt_payments_on_order_id", using: :btree
  add_index "ddt_payments", ["payment_method_id"], name: "index_ddt_payments_on_payment_method_id", using: :btree
  add_index "ddt_payments", ["shop_id"], name: "index_ddt_payments_on_shop_id", using: :btree

  create_table "ddt_preferences", force: true do |t|
    t.string   "key"
    t.text     "value",      limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ddt_print_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "printer_id"
    t.text     "content",    limit: 16777215
    t.integer  "times"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "record_id"
  end

  add_index "ddt_print_records", ["branch_id"], name: "index_ddt_print_records_on_branch_id", using: :btree
  add_index "ddt_print_records", ["printer_id"], name: "index_ddt_print_records_on_printer_id", using: :btree
  add_index "ddt_print_records", ["shop_id"], name: "index_ddt_print_records_on_shop_id", using: :btree

  create_table "ddt_print_settings", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "page_header"
    t.string   "page_footer"
    t.boolean  "is_show_joke",   default: true
    t.boolean  "is_show_qrcode", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_print_settings", ["branch_id"], name: "index_ddt_print_settings_on_branch_id", using: :btree
  add_index "ddt_print_settings", ["shop_id"], name: "index_ddt_print_settings_on_shop_id", using: :btree

  create_table "ddt_printers", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "type"
    t.string   "name"
    t.string   "number"
    t.string   "api_key"
    t.string   "member_code"
    t.string   "phone"
    t.boolean  "enable",       default: true
    t.integer  "times",        default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.boolean  "is_print_all", default: true
  end

  add_index "ddt_printers", ["branch_id"], name: "index_ddt_printers_on_branch_id", using: :btree
  add_index "ddt_printers", ["shop_id"], name: "index_ddt_printers_on_shop_id", using: :btree

  create_table "ddt_printers_categories", id: false, force: true do |t|
    t.integer "printer_id"
    t.integer "category_id"
  end

  add_index "ddt_printers_categories", ["printer_id", "category_id"], name: "index_ddt_printers_categories", using: :btree

  create_table "ddt_printers_products", id: false, force: true do |t|
    t.integer "printer_id"
    t.integer "product_id"
  end

  add_index "ddt_printers_products", ["printer_id"], name: "index_ddt_printers_products_on_printer_id", using: :btree
  add_index "ddt_printers_products", ["product_id"], name: "index_ddt_printers_products_on_product_id", using: :btree

  create_table "ddt_product_option_types", force: true do |t|
    t.integer "shop_id"
    t.integer "branch_id"
    t.integer "product_id"
    t.integer "option_type_id"
    t.integer "position"
  end

  add_index "ddt_product_option_types", ["branch_id"], name: "index_ddt_product_option_types_on_branch_id", using: :btree
  add_index "ddt_product_option_types", ["option_type_id"], name: "index_ddt_product_option_types_on_option_type_id", using: :btree
  add_index "ddt_product_option_types", ["product_id"], name: "index_ddt_product_option_types_on_product_id", using: :btree
  add_index "ddt_product_option_types", ["shop_id"], name: "index_ddt_product_option_types_on_shop_id", using: :btree

  create_table "ddt_products", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "name",                limit: 191
    t.text     "description",         limit: 16777215
    t.string   "keywords"
    t.string   "unit_name",                            default: "份"
    t.integer  "position",                             default: 10
    t.boolean  "support_delivery",                     default: true
    t.boolean  "support_reservation",                  default: true
    t.boolean  "support_eat_in_hall",                  default: true
    t.boolean  "sale_on_monday",                       default: true
    t.boolean  "sale_on_tuesday",                      default: true
    t.boolean  "sale_on_wednesday",                    default: true
    t.boolean  "sale_on_thursday",                     default: true
    t.boolean  "sale_on_friday",                       default: true
    t.boolean  "sale_on_saturday",                     default: true
    t.boolean  "sale_on_sunday",                       default: true
    t.datetime "availabled_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "promotionable",                        default: true
    t.boolean  "on_shelf",                             default: true
    t.string   "name_abbr"
  end

  add_index "ddt_products", ["branch_id"], name: "index_ddt_products_on_branch_id", using: :btree
  add_index "ddt_products", ["shop_id"], name: "index_ddt_products_on_shop_id", using: :btree

  create_table "ddt_products_tags", id: false, force: true do |t|
    t.integer "product_id"
    t.integer "tag_id"
  end

  add_index "ddt_products_tags", ["product_id"], name: "add_index_ddt_products_tags_on_product_id", using: :btree
  add_index "ddt_products_tags", ["tag_id"], name: "add_index_ddt_products_tags_on_tag_id", using: :btree

  create_table "ddt_promotion_actions", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "promotion_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.text     "preferences",                limit: 16777215
    t.integer  "abstract_coupon_version_id"
  end

  add_index "ddt_promotion_actions", ["branch_id"], name: "index_ddt_promotion_actions_on_branch_id", using: :btree
  add_index "ddt_promotion_actions", ["id", "type"], name: "index_ddt_promotion_actions_on_id_and_type", length: {"id"=>nil, "type"=>191}, using: :btree
  add_index "ddt_promotion_actions", ["promotion_id"], name: "index_ddt_promotion_actions_on_promotion_id", using: :btree
  add_index "ddt_promotion_actions", ["shop_id"], name: "index_ddt_promotion_actions_on_shop_id", using: :btree

  create_table "ddt_promotion_events", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "base_user_id"
    t.integer  "order_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_promotion_events", ["base_user_id"], name: "index_ddt_promotion_events_on_base_user_id", using: :btree
  add_index "ddt_promotion_events", ["branch_id"], name: "index_ddt_promotion_events_on_branch_id", using: :btree
  add_index "ddt_promotion_events", ["id", "type"], name: "index_ddt_promotion_events_on_id_and_type", length: {"id"=>nil, "type"=>191}, using: :btree
  add_index "ddt_promotion_events", ["order_id"], name: "index_ddt_promotion_events_on_order_id", using: :btree
  add_index "ddt_promotion_events", ["shop_id"], name: "index_ddt_promotion_events_on_shop_id", using: :btree

  create_table "ddt_promotion_rules", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "promotion_id"
    t.text     "preferences",  limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "ddt_promotion_rules", ["branch_id"], name: "index_ddt_promotion_rules_on_branch_id", using: :btree
  add_index "ddt_promotion_rules", ["id", "type"], name: "index_ddt_promotion_rules_on_id_and_type", length: {"id"=>nil, "type"=>191}, using: :btree
  add_index "ddt_promotion_rules", ["promotion_id"], name: "index_ddt_promotion_rules_on_promotion_id", using: :btree
  add_index "ddt_promotion_rules", ["shop_id"], name: "index_ddt_promotion_rules_on_shop_id", using: :btree

  create_table "ddt_promotions", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "name"
    t.text     "description",           limit: 16777215
    t.string   "type"
    t.string   "match_policy",                           default: "match_all"
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.integer  "usage_limit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.boolean  "hide_header_in_weixin",                  default: false
    t.string   "keywords"
    t.string   "branch_scope_policy",                    default: "match_all_branches"
    t.boolean  "show_on_index",                          default: false
  end

  add_index "ddt_promotions", ["branch_id"], name: "index_ddt_promotions_on_branch_id", using: :btree
  add_index "ddt_promotions", ["id", "type"], name: "index_ddt_promotions_on_id_and_type", length: {"id"=>nil, "type"=>191}, using: :btree
  add_index "ddt_promotions", ["shop_id"], name: "index_ddt_promotions_on_shop_id", using: :btree

  create_table "ddt_promotions_branches", id: false, force: true do |t|
    t.integer "promotion_id"
    t.integer "branch_id"
  end

  add_index "ddt_promotions_branches", ["branch_id"], name: "index_ddt_promotions_branches_on_branch_id", using: :btree
  add_index "ddt_promotions_branches", ["promotion_id"], name: "index_ddt_promotions_branches_on_promotion_id", using: :btree

  create_table "ddt_promotions_line_items", id: false, force: true do |t|
    t.integer "promotion_id"
    t.integer "line_item_id"
  end

  add_index "ddt_promotions_line_items", ["line_item_id"], name: "index_ddt_promotions_line_items_on_line_item_id", using: :btree
  add_index "ddt_promotions_line_items", ["promotion_id"], name: "index_ddt_promotions_line_items_on_promotion_id", using: :btree

  create_table "ddt_promotions_orders", id: false, force: true do |t|
    t.integer "promotion_id"
    t.integer "order_id"
  end

  add_index "ddt_promotions_orders", ["order_id"], name: "index_ddt_promotions_orders_on_order_id", using: :btree
  add_index "ddt_promotions_orders", ["promotion_id"], name: "index_ddt_promotions_orders_on_promotion_id", using: :btree

  create_table "ddt_promotions_promotion_events", id: false, force: true do |t|
    t.integer "promotion_id"
    t.integer "promotion_event_id"
  end

  add_index "ddt_promotions_promotion_events", ["promotion_event_id"], name: "index_ddt_ppe_on_promotion_event", using: :btree
  add_index "ddt_promotions_promotion_events", ["promotion_id"], name: "index_ddt_ppe_on_promotion", using: :btree

  create_table "ddt_qrcode_scan_relations", force: true do |t|
    t.integer  "base_qr_code_scene_id"
    t.integer  "scaner_id"
    t.string   "scaner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_qrcode_scan_relations", ["base_qr_code_scene_id"], name: "index_ddt_qrcode_scan_relations_on_base_qr_code_scene_id", using: :btree
  add_index "ddt_qrcode_scan_relations", ["scaner_id", "scaner_type"], name: "index_scanner_of_qrcode_scan_relationship", length: {"scaner_id"=>nil, "scaner_type"=>191}, using: :btree

  create_table "ddt_queue_modules", force: true do |t|
    t.integer  "shop_id"
    t.datetime "expired_at"
    t.boolean  "enable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_queue_modules", ["shop_id"], name: "index_ddt_queue_modules_on_shop_id", using: :btree

  create_table "ddt_queue_settings", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "name"
    t.string   "queue_url"
    t.string   "queue_qr_code"
    t.integer  "guest_num_le"
    t.time     "start_at"
    t.time     "end_at"
    t.string   "queue_no_prefix"
    t.integer  "current_queue_head_id"
    t.string   "last_push_queue_item_no"
    t.datetime "last_push_queue_item_at"
    t.boolean  "enabled",                 default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_queue_settings", ["branch_id"], name: "index_ddt_queue_settings_on_branch_id", using: :btree
  add_index "ddt_queue_settings", ["current_queue_head_id"], name: "index_ddt_queue_settings_on_current_queue_head_id", using: :btree
  add_index "ddt_queue_settings", ["shop_id"], name: "index_ddt_queue_settings_on_shop_id", using: :btree

  create_table "ddt_recharge_products", force: true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.decimal  "price",           precision: 8, scale: 2, default: 100.0
    t.decimal  "decimal",         precision: 8, scale: 2, default: 100.0
    t.decimal  "recharge_amount", precision: 8, scale: 2, default: 100.0
    t.integer  "position"
    t.integer  "sales_count",                             default: 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_recharge_products", ["shop_id"], name: "index_ddt_recharge_products_on_shop_id", using: :btree

  create_table "ddt_reservation_infos", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "reservation_order_id"
    t.integer  "table_zone_id"
    t.integer  "reservation_time_point_id"
    t.datetime "reservation_date"
    t.time     "time_point"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "phone"
    t.string   "gender"
    t.integer  "table_id"
  end

  add_index "ddt_reservation_infos", ["branch_id"], name: "index_ddt_reservation_infos_on_branch_id", using: :btree
  add_index "ddt_reservation_infos", ["reservation_order_id"], name: "index_ddt_reservation_infos_on_reservation_order_id", using: :btree
  add_index "ddt_reservation_infos", ["reservation_time_point_id"], name: "index_ddt_reservation_infos_on_reservation_time_point_id", using: :btree
  add_index "ddt_reservation_infos", ["shop_id"], name: "index_ddt_reservation_infos_on_shop_id", using: :btree
  add_index "ddt_reservation_infos", ["table_id"], name: "index_ddt_reservation_infos_on_table_id", using: :btree
  add_index "ddt_reservation_infos", ["table_zone_id"], name: "index_ddt_reservation_infos_on_table_zone_id", using: :btree

  create_table "ddt_reservation_modules", force: true do |t|
    t.integer  "shop_id"
    t.datetime "expired_at"
    t.boolean  "enable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_reservation_modules", ["shop_id"], name: "index_ddt_reservation_modules_on_shop_id", using: :btree

  create_table "ddt_reservation_settings", force: true do |t|
    t.decimal  "average_consumption",  precision: 8, scale: 2, default: 30.0
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "prepayment_type",                              default: "only_table"
    t.integer  "max_reservation_days",                         default: 7
  end

  add_index "ddt_reservation_settings", ["branch_id"], name: "index_ddt_reservation_settings_on_branch_id", using: :btree
  add_index "ddt_reservation_settings", ["shop_id"], name: "index_ddt_reservation_settings_on_shop_id", using: :btree

  create_table "ddt_reservation_time_points", force: true do |t|
    t.time     "time_point"
    t.integer  "table_zone_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
  end

  add_index "ddt_reservation_time_points", ["branch_id"], name: "index_ddt_reservation_time_points_on_branch_id", using: :btree
  add_index "ddt_reservation_time_points", ["shop_id"], name: "index_ddt_reservation_time_points_on_shop_id", using: :btree
  add_index "ddt_reservation_time_points", ["table_zone_id"], name: "index_ddt_reservation_time_points_on_table_zone_id", using: :btree

  create_table "ddt_roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "permissions",   limit: 16777215
    t.string   "display_name"
    t.integer  "shop_id"
    t.boolean  "builtin",                        default: false
  end

  add_index "ddt_roles", ["name", "resource_type", "resource_id"], name: "index_ddt_roles_on_name_and_resource_type_and_resource_id", length: {"name"=>191, "resource_type"=>191, "resource_id"=>nil}, using: :btree
  add_index "ddt_roles", ["name"], name: "index_ddt_roles_on_name", length: {"name"=>191}, using: :btree
  add_index "ddt_roles", ["shop_id"], name: "index_ddt_roles_on_shop_id", using: :btree

  create_table "ddt_search_groups", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "name"
    t.text     "preference", limit: 16777215
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_search_groups", ["branch_id"], name: "index_ddt_search_groups_on_branch_id", using: :btree
  add_index "ddt_search_groups", ["shop_id"], name: "index_ddt_search_groups_on_shop_id", using: :btree

  create_table "ddt_service_periods", force: true do |t|
    t.integer  "branch_id"
    t.integer  "shop_id"
    t.time     "start_at",   default: '2000-01-01 09:00:00'
    t.time     "end_at",     default: '2000-01-01 21:00:00'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_service_periods", ["branch_id"], name: "index_ddt_service_periods_on_branch_id", using: :btree
  add_index "ddt_service_periods", ["shop_id"], name: "index_ddt_service_periods_on_shop_id", using: :btree

  create_table "ddt_service_product_orders", force: true do |t|
    t.string   "out_trade_no"
    t.string   "subject"
    t.string   "product_type"
    t.decimal  "price",              precision: 8, scale: 2
    t.integer  "quantity"
    t.decimal  "discount",           precision: 8, scale: 2
    t.string   "workflow_state"
    t.integer  "shop_id"
    t.integer  "service_product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_service_product_orders", ["service_product_id"], name: "index_on_service_product_id", using: :btree
  add_index "ddt_service_product_orders", ["shop_id"], name: "index_ddt_service_product_orders_on_shop_id", using: :btree

  create_table "ddt_service_products", force: true do |t|
    t.string   "subject"
    t.decimal  "price",       precision: 8, scale: 2
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "preferences"
    t.string   "type"
    t.boolean  "is_offline",                          default: false
  end

  create_table "ddt_sharable_coupons", force: true do |t|
    t.integer  "shop_id"
    t.integer  "base_user_id"
    t.integer  "abstract_coupon_version_id"
    t.integer  "count"
    t.integer  "receive_count",              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_sharable_coupons", ["abstract_coupon_version_id"], name: "index_ddt_sharable_coupons_on_abstract_coupon_version_id", using: :btree
  add_index "ddt_sharable_coupons", ["base_user_id"], name: "index_ddt_sharable_coupons_on_base_user_id", using: :btree
  add_index "ddt_sharable_coupons", ["shop_id"], name: "index_ddt_sharable_coupons_on_shop_id", using: :btree

  create_table "ddt_shipments", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.integer  "address_id"
    t.integer  "delivery_zone_id"
    t.integer  "delivery_time_id"
    t.integer  "delivery_man_id"
    t.string   "state"
    t.datetime "shipping_at"
    t.datetime "shipped_at"
    t.string   "content"
    t.string   "name"
    t.string   "phone"
    t.decimal  "cost",             precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "adjustment_total", precision: 8, scale: 2, default: 0.0
    t.date     "delivery_date"
    t.decimal  "latitude",         precision: 9, scale: 6
    t.decimal  "longitude",        precision: 9, scale: 6
  end

  add_index "ddt_shipments", ["address_id"], name: "index_ddt_shipments_on_address_id", using: :btree
  add_index "ddt_shipments", ["branch_id"], name: "index_ddt_shipments_on_branch_id", using: :btree
  add_index "ddt_shipments", ["delivery_man_id"], name: "index_ddt_shipments_on_delivery_man_id", using: :btree
  add_index "ddt_shipments", ["delivery_time_id"], name: "index_ddt_shipments_on_delivery_time_id", using: :btree
  add_index "ddt_shipments", ["delivery_zone_id"], name: "index_ddt_shipments_on_delivery_zone_id", using: :btree
  add_index "ddt_shipments", ["order_id"], name: "index_ddt_shipments_on_order_id", using: :btree
  add_index "ddt_shipments", ["shop_id"], name: "index_ddt_shipments_on_shop_id", using: :btree

  create_table "ddt_shop_recharge_records", force: true do |t|
    t.integer  "shop_id"
    t.decimal  "price",                           precision: 8, scale: 2
    t.string   "recharge_type"
    t.datetime "beginning_time"
    t.integer  "increment_days",                                          default: 365
    t.datetime "ending_time"
    t.text     "note",           limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_shop_recharge_records", ["shop_id"], name: "index_ddt_shop_recharge_records_on_shop_id", using: :btree

  create_table "ddt_shops", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.boolean  "is_open"
    t.datetime "expiration_time"
    t.string   "telephone"
    t.text     "introduction",                         limit: 16777215
    t.string   "image"
    t.string   "rect_image"
    t.string   "charge_method"
    t.boolean  "use_custom_brand"
    t.string   "agent_no"
    t.string   "custom_brand_name"
    t.string   "custom_brand_link"
    t.boolean  "enable_foreign"
    t.string   "foreign_currency_symbol",                                                       default: "¥"
    t.string   "vip_logo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "accounts_count"
    t.integer  "base_users_count",                                                              default: 0
    t.integer  "users_count",                                                                   default: 0
    t.integer  "web_users_count",                                                               default: 0
    t.integer  "phone_users_count",                                                             default: 0
    t.datetime "deleted_at"
    t.integer  "branches_count",                                                                default: 0
    t.integer  "coupon_images_storage",                                                         default: 0
    t.boolean  "hide_support_brand",                                                            default: false
    t.integer  "last_scene_id",                                                                 default: 0
    t.integer  "placed_orders_count",                                                           default: 0
    t.integer  "max_branches_limit",                                                            default: 1
    t.string   "reservation_img"
    t.string   "order_in_seat_img"
    t.string   "delivery_img"
    t.string   "queue_img"
    t.string   "pay_online_img"
    t.text     "search_words",                         limit: 16777215
    t.boolean  "force_fetch_user_info",                                                         default: false
    t.string   "sina_weibo"
    t.string   "service_email"
    t.boolean  "use_sms_validation"
    t.boolean  "is_set_as_third_part_url",                                                      default: true
    t.string   "foreign_time_zone",                                                             default: "Beijing"
    t.boolean  "is_custom_system_weixin_notification",                                          default: false
    t.string   "custom_system_weixin_template_id"
    t.decimal  "foreign_tax_rate",                                      precision: 6, scale: 3, default: 0.0
    t.string   "track_from"
    t.boolean  "is_valid_phone",                                                                default: false
    t.string   "custom_domain"
    t.boolean  "debug",                                                                         default: false
  end

  create_table "ddt_short_message_settings", force: true do |t|
    t.integer  "shop_id"
    t.boolean  "use_sms"
    t.boolean  "use_validation_sms"
    t.boolean  "use_order_sms"
    t.integer  "used_count",         default: 0
    t.integer  "max_count",          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_short_message_settings", ["shop_id"], name: "index_ddt_short_message_settings_on_shop_id", using: :btree

  create_table "ddt_short_messages", force: true do |t|
    t.string   "to"
    t.text     "body"
    t.string   "message_number"
    t.string   "date_created"
    t.string   "sms_type"
    t.integer  "size"
    t.string   "template"
    t.text     "parameters"
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "ddt_short_messages", ["branch_id"], name: "index_ddt_short_messages_on_branch_id", using: :btree
  add_index "ddt_short_messages", ["owner_id", "owner_type"], name: "index_ddt_short_messages_on_owner_id_and_owner_type", length: {"owner_id"=>nil, "owner_type"=>191}, using: :btree
  add_index "ddt_short_messages", ["shop_id"], name: "index_ddt_short_messages_on_shop_id", using: :btree

  create_table "ddt_sign_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "base_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_sign_records", ["base_user_id"], name: "index_ddt_sign_records_on_base_user_id", using: :btree
  add_index "ddt_sign_records", ["shop_id"], name: "index_ddt_sign_records_on_shop_id", using: :btree

  create_table "ddt_state_changes", force: true do |t|
    t.string   "stateful_type"
    t.integer  "stateful_id"
    t.string   "state_name"
    t.string   "previous_state"
    t.string   "next_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "operator_type"
    t.integer  "operator_id"
  end

  add_index "ddt_state_changes", ["operator_type", "operator_id"], name: "index_ddt_state_changes_on_operator_type_and_operator_id", length: {"operator_type"=>191, "operator_id"=>nil}, using: :btree
  add_index "ddt_state_changes", ["stateful_type", "stateful_id"], name: "index_ddt_state_changes_on_stateful_type_and_stateful_id", length: {"stateful_type"=>191, "stateful_id"=>nil}, using: :btree

  create_table "ddt_table_zones", force: true do |t|
    t.string   "name"
    t.integer  "tables_count_for_reservation",                         default: 0
    t.decimal  "min_reservation_price",        precision: 8, scale: 2, default: 0.0
    t.integer  "branch_id"
    t.integer  "tables_count",                                         default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.decimal  "reservation_price",            precision: 8, scale: 2, default: 0.0
    t.integer  "reservation_price_percent",                            default: 100
  end

  add_index "ddt_table_zones", ["branch_id"], name: "index_ddt_table_zones_on_branch_id", using: :btree
  add_index "ddt_table_zones", ["shop_id"], name: "index_ddt_table_zones_on_shop_id", using: :btree

  create_table "ddt_tables", force: true do |t|
    t.string   "name"
    t.integer  "table_zone_id"
    t.integer  "current_order_id"
    t.string   "workflow_state",   default: "idle"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.datetime "last_opened_at"
    t.integer  "capacity"
  end

  add_index "ddt_tables", ["branch_id"], name: "index_ddt_tables_on_branch_id", using: :btree
  add_index "ddt_tables", ["current_order_id"], name: "index_ddt_tables_on_current_order_id", using: :btree
  add_index "ddt_tables", ["shop_id"], name: "index_ddt_tables_on_shop_id", using: :btree
  add_index "ddt_tables", ["table_zone_id"], name: "index_ddt_tables_on_table_zone_id", using: :btree

  create_table "ddt_tags", force: true do |t|
    t.string   "name"
    t.integer  "count",      default: 0
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_tags", ["branch_id"], name: "index_ddt_tags_on_branch_id", using: :btree
  add_index "ddt_tags", ["count"], name: "add_index_ddt_tags_on_count", using: :btree
  add_index "ddt_tags", ["name"], name: "add_index_ddt_tags_on_name", length: {"name"=>191}, using: :btree
  add_index "ddt_tags", ["shop_id"], name: "index_ddt_tags_on_shop_id", using: :btree

  create_table "ddt_targets", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "targetable_id"
    t.string   "targetable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_targets", ["branch_id"], name: "index_ddt_targets_on_branch_id", using: :btree
  add_index "ddt_targets", ["shop_id"], name: "index_ddt_targets_on_shop_id", using: :btree
  add_index "ddt_targets", ["targetable_id", "targetable_type"], name: "index_ddt_targets_on_targetable_id_and_targetable_type", length: {"targetable_id"=>nil, "targetable_type"=>191}, using: :btree

  create_table "ddt_targets_customs", force: true do |t|
    t.integer  "key"
    t.string   "target_ids"
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_targets_customs", ["branch_id"], name: "index_ddt_targets_customs_on_branch_id", using: :btree
  add_index "ddt_targets_customs", ["key"], name: "idx_key", using: :btree
  add_index "ddt_targets_customs", ["shop_id"], name: "index_ddt_targets_customs_on_shop_id", using: :btree

  create_table "ddt_unique_users", force: true do |t|
    t.string   "gonghao_open_id"
    t.string   "user_open_id",    limit: 191
    t.string   "nickname",        limit: 191
    t.string   "headimgurl"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "sex"
    t.string   "province"
    t.string   "city"
    t.string   "country"
    t.string   "privilege"
    t.string   "unionid"
  end

  add_index "ddt_unique_users", ["user_open_id"], name: "user_open_id_index", :length => {"user_open_id" => 191}, unique: true, using: :btree

  create_table "ddt_users_branches_favoriteship", force: true do |t|
    t.integer "base_user_id"
    t.integer "branch_id"
  end

  add_index "ddt_users_branches_favoriteship", ["base_user_id", "branch_id"], name: "index_ddt_users_branches_favoriteship", unique: true, using: :btree
  add_index "ddt_users_branches_favoriteship", ["base_user_id"], name: "index_ddt_users_branches_favoriteship_on_base_user_id", using: :btree
  add_index "ddt_users_branches_favoriteship", ["branch_id"], name: "index_ddt_users_branches_favoriteship_on_branch_id", using: :btree

  create_table "ddt_validation_codes", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_validation_codes", ["owner_id", "owner_type"], name: "index_ddt_validation_codes_on_owner_id_and_owner_type", length: {"owner_id"=>nil, "owner_type"=>191}, using: :btree

  create_table "ddt_variants", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "product_id"
    t.boolean  "is_master"
    t.string   "sku"
    t.decimal  "price",              precision: 8, scale: 2
    t.decimal  "vip_price",          precision: 8, scale: 2
    t.decimal  "cost_price",         precision: 8, scale: 2
    t.integer  "stock_quantity",                             default: 100
    t.integer  "sale_quantity",                              default: 0
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cache_name"
    t.string   "cache_options_text"
    t.string   "cache_image_url"
  end

  add_index "ddt_variants", ["branch_id"], name: "index_ddt_variants_on_branch_id", using: :btree
  add_index "ddt_variants", ["product_id"], name: "index_ddt_variants_on_product_id", using: :btree
  add_index "ddt_variants", ["shop_id"], name: "index_ddt_variants_on_shop_id", using: :btree

  create_table "ddt_variants_promotion_rules", id: false, force: true do |t|
    t.integer "variant_id"
    t.integer "promotion_rule_id"
  end

  add_index "ddt_variants_promotion_rules", ["promotion_rule_id"], name: "index_ddt_variants_promotion_rules_on_promotion_rule_id", using: :btree
  add_index "ddt_variants_promotion_rules", ["variant_id"], name: "index_ddt_variants_promotion_rules_on_variant_id", using: :btree

  create_table "ddt_vip_infos", force: true do |t|
    t.string   "phone"
    t.string   "name"
    t.integer  "vip_level_id"
    t.string   "pay_password_hash"
    t.decimal  "total_amount",      precision: 8, scale: 2, default: 0.0
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "vip_no"
    t.boolean  "is_verified",                               default: false
    t.string   "sex"
    t.string   "id_number"
    t.date     "birthday"
    t.string   "address"
    t.string   "email"
    t.text     "note"
    t.string   "avatar"
    t.boolean  "is_apply_vip",                              default: false
  end

  add_index "ddt_vip_infos", ["shop_id"], name: "index_ddt_vip_infos_on_shop_id", using: :btree
  add_index "ddt_vip_infos", ["vip_level_id"], name: "index_ddt_vip_infos_on_vip_level_id", using: :btree

  create_table "ddt_vip_levels", force: true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.decimal  "discount",               precision: 8, scale: 2, default: 1.0
    t.integer  "vip_infos_count",                                default: 0
    t.boolean  "auto_upgrade",                                   default: false
    t.decimal  "upgrade_total_amount",   precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "is_default",                                     default: false
    t.decimal  "upgrade_recharge_money", precision: 8, scale: 2
    t.integer  "upgrade_get_credits"
  end

  add_index "ddt_vip_levels", ["shop_id"], name: "index_ddt_vip_levels_on_shop_id", using: :btree

  create_table "ddt_waiter_service_items", force: true do |t|
    t.integer "shop_id"
    t.integer "branch_id"
    t.string  "name"
  end

  add_index "ddt_waiter_service_items", ["branch_id"], name: "index_ddt_waiter_service_items_on_branch_id", using: :btree
  add_index "ddt_waiter_service_items", ["shop_id"], name: "index_ddt_waiter_service_items_on_shop_id", using: :btree

  create_table "ddt_wallet_logs", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "wallet_id"
    t.integer  "order_id"
    t.integer  "frozenable_id"
    t.string   "reason"
    t.decimal  "amount",          precision: 8, scale: 2
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "frozenable_type"
  end

  add_index "ddt_wallet_logs", ["branch_id"], name: "index_ddt_wallet_logs_on_branch_id", using: :btree
  add_index "ddt_wallet_logs", ["frozenable_id"], name: "index_ddt_wallet_logs_on_frozenable_id", using: :btree
  add_index "ddt_wallet_logs", ["order_id"], name: "index_ddt_wallet_logs_on_order_id", using: :btree
  add_index "ddt_wallet_logs", ["shop_id"], name: "index_ddt_wallet_logs_on_shop_id", using: :btree
  add_index "ddt_wallet_logs", ["wallet_id"], name: "index_ddt_wallet_logs_on_wallet_id", using: :btree

  create_table "ddt_wallets", force: true do |t|
    t.integer  "shop_id"
    t.string   "type"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.integer  "credits",                                      default: 0
    t.decimal  "amount",               precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total_recharge_money", precision: 8, scale: 2, default: 0.0
    t.decimal  "total_get_amount",     precision: 8, scale: 2, default: 0.0
    t.decimal  "total_used_amount",    precision: 8, scale: 2, default: 0.0
    t.integer  "total_get_credits",                            default: 0
    t.integer  "total_used_credits",                           default: 0
    t.datetime "deleted_at"
  end

  add_index "ddt_wallets", ["id", "type"], name: "index_ddt_wallets_on_id_and_type", length: {"id"=>nil, "type"=>191}, using: :btree
  add_index "ddt_wallets", ["owner_id", "owner_type"], name: "index_ddt_wallets_on_owner_id_and_owner_type", length: {"owner_id"=>nil, "owner_type"=>191}, using: :btree
  add_index "ddt_wallets", ["shop_id"], name: "index_ddt_wallets_on_shop_id", using: :btree

  create_table "ddt_web_modules", force: true do |t|
    t.integer  "shop_id"
    t.datetime "expired_at"
    t.boolean  "enable"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_domain_url_validated", default: false
    t.string   "custom_domain_url"
    t.string   "cname_prefix"
    t.string   "bei_an_info"
    t.string   "nav_text_1"
    t.string   "nav_link_1"
    t.string   "nav_text_2"
    t.string   "nav_link_2"
    t.string   "title"
    t.string   "keywords"
    t.text     "description"
  end

  add_index "ddt_web_modules", ["custom_domain_url"], name: "index_ddt_web_modules_on_custom_domain_url", length: {"custom_domain_url"=>191}, using: :btree
  add_index "ddt_web_modules", ["shop_id"], name: "index_ddt_web_modules_on_shop_id", using: :btree

  create_table "ddt_wechat_accounts", force: true do |t|
    t.string   "token"
    t.string   "app_id"
    t.string   "app_secret"
    t.string   "gonghao_open_id"
    t.string   "public_account_name"
    t.string   "gonghao_type"
    t.boolean  "be_verified"
    t.text     "access_token",                           limit: 16777215
    t.datetime "last_update_access_token_at"
    t.boolean  "is_primary"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "wechat_introduce_url"
    t.string   "weixin_hao"
    t.integer  "default_branch_id"
    t.string   "jsapi_ticket"
    t.datetime "last_update_jsapi_ticket_at"
    t.boolean  "is_authorized",                                           default: false
    t.string   "component_verify_ticket"
    t.datetime "last_update_component_verify_ticket_at"
    t.string   "component_access_token"
    t.datetime "component_access_token_expired_at"
    t.string   "pre_auth_code"
    t.datetime "pre_auth_code_expired_at"
    t.string   "authorization_code"
    t.string   "authorizer_appid"
    t.string   "authorizer_access_token"
    t.datetime "authorizer_access_token_expired_at"
    t.string   "authorizer_refresh_token"
    t.text     "preferences"
    t.string   "nick_name"
    t.string   "head_img"
    t.integer  "service_type_info"
    t.integer  "verify_type_info"
    t.string   "user_name"
    t.string   "qrcode_url"
  end

  add_index "ddt_wechat_accounts", ["gonghao_open_id"], name: "index_ddt_wechat_accounts_on_gonghao_open_id", length: {"gonghao_open_id"=>191}, using: :btree
  add_index "ddt_wechat_accounts", ["shop_id"], name: "index_ddt_wechat_accounts_on_shop_id", using: :btree

  create_table "ddt_wechat_menus", force: true do |t|
    t.string   "name"
    t.string   "menu_type"
    t.string   "event_type"
    t.integer  "parent_id"
    t.integer  "subs_count"
    t.integer  "position"
    t.string   "url"
    t.string   "keyword"
    t.integer  "material_id"
    t.integer  "wechat_account_id"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_wechat_menus", ["material_id"], name: "index_ddt_wechat_menus_on_material_id", using: :btree
  add_index "ddt_wechat_menus", ["shop_id"], name: "index_ddt_wechat_menus_on_shop_id", using: :btree
  add_index "ddt_wechat_menus", ["wechat_account_id"], name: "index_ddt_wechat_menus_on_wechat_account_id", using: :btree

  create_table "ddt_wechat_modules", force: true do |t|
    t.integer  "shop_id"
    t.datetime "expired_at"
    t.boolean  "enable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_wechat_modules", ["shop_id"], name: "index_ddt_wechat_modules_on_shop_id", using: :btree

  create_table "ddt_wechat_share_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "user_id"
    t.string   "share_type"
    t.boolean  "verified",                       default: false
    t.string   "title"
    t.text     "desc"
    t.string   "link",               limit: 512
    t.string   "img_url"
    t.datetime "deleted_at"
    t.integer  "viewed_users_count",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trigger_timestamp",  limit: 8
  end

  add_index "ddt_wechat_share_records", ["shop_id"], name: "index_ddt_wechat_share_records_on_shop_id", using: :btree
  add_index "ddt_wechat_share_records", ["user_id"], name: "index_ddt_wechat_share_records_on_user_id", using: :btree

  create_table "ddt_wechat_subscribe_relationships", force: true do |t|
    t.string   "gonghao_open_id"
    t.string   "user_open_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ddt_wechat_users", force: true do |t|
    t.string   "user_open_id"
    t.string   "gonghao_open_id"
    t.integer  "orders_count"
    t.integer  "shop_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "unsubscribed_at"
  end

  add_index "ddt_wechat_users", ["shop_id"], name: "index_ddt_wechat_users_on_shop_id", using: :btree
  add_index "ddt_wechat_users", ["user_id"], name: "index_ddt_wechat_users_on_user_id", using: :btree

  create_table "ddt_wechat_view_records", force: true do |t|
    t.integer  "wechat_share_record_id"
    t.integer  "base_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_wechat_view_records", ["base_user_id", "wechat_share_record_id"], name: "index_ddt_wechat_view_records", unique: true, using: :btree
  add_index "ddt_wechat_view_records", ["base_user_id"], name: "index_ddt_wechat_view_records_on_base_user_id", using: :btree
  add_index "ddt_wechat_view_records", ["wechat_share_record_id"], name: "index_ddt_wechat_view_records_on_wechat_share_record_id", using: :btree

  create_table "ddt_wechatpay_feedbacks", force: true do |t|
    t.integer "shop_id"
    t.string  "feedback_id"
    t.string  "appid"
    t.string  "openid"
    t.string  "trade_id"
    t.text    "body",        limit: 16777215
    t.string  "msg_type"
  end

  add_index "ddt_wechatpay_feedbacks", ["shop_id"], name: "index_ddt_wechatpay_feedbacks_on_shop_id", using: :btree

  create_table "ddt_wechatpay_warnings", force: true do |t|
    t.integer "shop_id"
    t.string  "error_type"
    t.string  "appid"
    t.text    "description",   limit: 16777215
    t.text    "alarm_content", limit: 16777215
    t.text    "body",          limit: 16777215
  end

  add_index "ddt_wechatpay_warnings", ["shop_id"], name: "index_ddt_wechatpay_warnings_on_shop_id", using: :btree

  create_table "ddt_withdraws", force: true do |t|
    t.integer  "shop_id"
    t.string   "alipay_account_id"
    t.string   "alipay_account_name"
    t.decimal  "residual",             precision: 8, scale: 2
    t.decimal  "amount",               precision: 8, scale: 2
    t.integer  "collection_wallet_id"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  add_index "ddt_withdraws", ["collection_wallet_id"], name: "index_ddt_withdraws_on_collection_wallet_id", using: :btree
  add_index "ddt_withdraws", ["shop_id"], name: "index_ddt_withdraws_on_shop_id", using: :btree
  add_index "ddt_withdraws", ["state"], name: "index_ddt_withdraws_on_state", length: {"state"=>191}, using: :btree

  create_table "ddt_zones", force: true do |t|
    t.string   "name"
    t.integer  "parent_zone_id"
    t.integer  "shop_id"
    t.integer  "branches_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddt_zones", ["parent_zone_id"], name: "index_ddt_zones_on_parent_zone_id", using: :btree
  add_index "ddt_zones", ["shop_id"], name: "index_ddt_zones_on_shop_id", using: :btree

  create_table "impressions", force: true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message",             limit: 16777215
    t.text     "referrer",            limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", length: {"controller_name"=>191, "action_name"=>191, "ip_address"=>191}, using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", length: {"controller_name"=>191, "action_name"=>191, "request_hash"=>191}, using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", length: {"controller_name"=>191, "action_name"=>191, "session_hash"=>191}, using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", length: {"impressionable_type"=>191, "impressionable_id"=>nil, "ip_address"=>191}, using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", length: {"impressionable_type"=>191, "impressionable_id"=>nil, "request_hash"=>191}, using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", length: {"impressionable_type"=>191, "impressionable_id"=>nil, "session_hash"=>191}, using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>191, "message"=>191, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", length: {"item_type"=>191, "item_id"=>nil}, using: :btree

  end
end
