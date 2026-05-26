class AddItemableInfoToLineItem < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_line_items, :unit_name
      add_column :ddt_line_items, :unit_name, :string
      add_column :ddt_line_items, :vip_price, :decimal, precision: 8, scale: 2
      add_column :ddt_line_items, :category_names, :string
      add_column :ddt_line_items, :enable_discount, :boolean
      add_column :ddt_line_items, :order_change_log_id, :integer
      add_column :ddt_line_items, :is_subtract, :boolean, default: false
      add_column :ddt_line_items, :source_line_item_id, :integer
      add_column :ddt_line_items, :subtract_quantity, :integer, default: 0
      add_column :ddt_line_items, :subtract_reason, :string
      add_column :ddt_line_items, :product_name, :string
    end

    add_column :ddt_products, :cache_category_names, :string unless column_exists? :ddt_products, :cache_category_names

    execute <<-SQL.strip_heredoc
      UPDATE ddt_products p
        SET cache_category_names = (
          SELECT STRING_AGG(c.name, ' ')
            FROM ddt_categories c
            LEFT JOIN ddt_categories_products cp ON c.id = cp.category_id
            WHERE cp.product_id = p.id
        );
    SQL

    # variant
    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items l
        SET
          unit_name = p.unit_name,
          vip_price = v.vip_price,
          category_names = p.cache_category_names,
          enable_discount = p.enable_discount
        FROM ddt_variants v
        JOIN ddt_products p ON p.id = v.product_id
        WHERE v.id = l.itemable_id
          AND l.itemable_type = 'Ddt::Variant';
    SQL
    # combo_package
    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items l
        SET
          unit_name = c.unit_name,
          vip_price = l.price,
          category_names = '',
          enable_discount = c.enable_discount
        FROM ddt_combo_packages cp
        JOIN ddt_combos c ON c.id = cp.combo_id
        WHERE cp.id = l.itemable_id
          AND l.itemable_type = 'Ddt::ComboPackage';
    SQL
    # variant_package
    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items l
        SET
          unit_name = p.unit_name,
          vip_price = v.vip_price * vp.weight,
          category_names = p.cache_category_names,
          enable_discount = p.enable_discount
        FROM ddt_variant_packages vp
        JOIN ddt_variants v ON v.id = vp.variant_id
        JOIN ddt_products p ON p.id = v.product_id
        WHERE vp.id = l.itemable_id
          AND l.itemable_type = 'Ddt::VariantPackage';
    SQL
    # AbstractCouponVersion
    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items
        SET
          unit_name = '张',
          vip_price = price,
          category_names = '',
          enable_discount = FALSE
        WHERE itemable_type IN (
          'Ddt::AbstractCouponVersion',
          'Ddt::GrouponVersion',
          'Ddt::VoucherVersion');
    SQL
    # recharge_product
    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items
        SET
          unit_name = '',
          vip_price = price,
          category_names = '',
          enable_discount = FALSE
        WHERE itemable_type = 'Ddt::RechargeProduct';
    SQL
  end

  def down
    remove_column :ddt_line_items, :unit_name
    remove_column :ddt_line_items, :vip_price
    remove_column :ddt_line_items, :category_names
    remove_column :ddt_line_items, :enable_discount
    remove_column :ddt_line_items, :order_change_log_id
    remove_column :ddt_line_items, :is_subtract
    remove_column :ddt_line_items, :source_line_item_id
    remove_column :ddt_line_items, :subtract_quantity
    remove_column :ddt_line_items, :subtract_reason
    remove_column :ddt_line_items, :product_name
  end
end
