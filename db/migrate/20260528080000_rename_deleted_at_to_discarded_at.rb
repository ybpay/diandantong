# Rename all `deleted_at` columns to `discarded_at` to match Discard gem conventions.
# Previously the codebase used Paranoia (deleted_at) with a Discard override.
# Now we use Discard's default column name `discarded_at` natively.
class RenameDeletedAtToDiscardedAt < ActiveRecord::Migration[8.1]
  TABLES = %i[
    ddt_abstract_coupon_versions
    ddt_accounts
    ddt_addresses
    ddt_base_qr_code_scenes
    ddt_base_users
    ddt_branches
    ddt_categories
    ddt_combo_items
    ddt_combos
    ddt_discount_plans
    ddt_form_contents
    ddt_form_elements
    ddt_line_items
    ddt_option_types
    ddt_option_values
    ddt_order_change_logs
    ddt_orders
    ddt_pay_items
    ddt_pay_methods
    ddt_payments
    ddt_products
    ddt_promotion_actions
    ddt_recharge_products
    ddt_shift_items
    ddt_shifts
    ddt_shops
    ddt_tables
    ddt_tick_accounts
    ddt_temp_recharge_products
    ddt_unique_users
    ddt_variants
    ddt_vip_infos
    ddt_vip_levels
    ddt_wallets
    ddt_wechat_share_records
    ddt_wechat_users
    ddt_agents
    ddt_adjustments
  ].freeze

  def up
    TABLES.each do |table|
      if column_exists?(table, :deleted_at) && !column_exists?(table, :discarded_at)
        rename_column table, :deleted_at, :discarded_at
      end
    end

    # Update indexes that reference deleted_at
    rename_index_columns
  end

  def down
    TABLES.each do |table|
      if column_exists?(table, :discarded_at) && !column_exists?(table, :deleted_at)
        rename_column table, :discarded_at, :deleted_at
      end
    end

    # Revert indexes
    rename_index_columns(:down)
  end

  private

  def rename_index_columns(direction = :up)
    from = direction == :up ? :deleted_at : :discarded_at
    to   = direction == :up ? :discarded_at : :deleted_at

    # ddt_accounts: unique index on [email, deleted_at]
    swap_index :ddt_accounts, 'ddt_accounts_email', [from], [to]

    # ddt_accounts: unique index on [login_id, deleted_at]
    swap_index :ddt_accounts, 'index_ddt_accounts_on_login_id_and_deleted_at', [from], [to]

    # ddt_categories: index on deleted_at
    swap_index :ddt_categories, 'index_ddt_categories_on_deleted_at', [from], [to]
  end

  def swap_index(table, old_name, from_cols, to_cols)
    return unless index_exists?(table, old_name)
    columns = connection.indexes(table).find { |i| i.name == old_name }&.columns
    return unless columns

    new_columns = columns.map { |c| from_cols.include?(c.to_sym) ? to_cols[from_cols.index(c.to_sym)] : c }
    remove_index table, name: old_name
    add_index table, new_columns, name: old_name.gsub(/deleted_at/, to.to_s), unique: true
  rescue => e
    warn "Index migration skipped for #{table}.#{old_name}: #{e.message}"
  end
end
