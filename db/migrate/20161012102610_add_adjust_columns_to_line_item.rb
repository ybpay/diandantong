class AddAdjustColumnsToLineItem < ActiveRecord::Migration
  def change
    if !column_exists? :ddt_line_items, :enjoy_vip_price
      add_column :ddt_line_items, :enjoy_vip_price, :boolean, null: false, default: false
    end
    if !column_exists? :ddt_line_items, :enjoy_custom_price
      add_column :ddt_line_items, :enjoy_custom_price, :boolean, null: false, default: false
    end

    execute "UPDATE ddt_line_items set enjoy_custom_price = 1 where change_price_at is not null"
    execute "UPDATE ddt_line_items set enjoy_vip_price = 0"
    execute <<-SQL
      UPDATE ddt_line_items as l
      LEFT JOIN ddt_orders as o ON l.order_id = o.id
      SET enjoy_vip_price = 1 
      WHERE itemable_type in ('Ddt::Variant', 'Ddt::ComboPackage', 'Ddt::VariantPackage')
      AND o.vip_info_id IS NOT NULL
      AND l.gift = 0
      AND l.enjoy_custom_price = 0
      AND l.vip_price != 0
      AND l.original_price != 0
      AND l.price = l.vip_price
      AND l.vip_price < l.original_price
    SQL

  end
end
