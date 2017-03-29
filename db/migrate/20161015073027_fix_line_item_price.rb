class FixLineItemPrice < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_line_items, :price_bak
      add_column :ddt_line_items, :price_bak, :decimal, precision: 10, scale: 2
    end
    execute "UPDATE ddt_line_items SET price_bak = price"
    execute "UPDATE ddt_line_items SET price = original_price where gift=1 and original_price is not null";
    execute "UPDATE ddt_line_items SET price = original_price where enjoy_vip_price=1 and original_price is not null";
    execute "UPDATE ddt_line_items SET price = original_price where enjoy_custom_price=1 and original_price is not null";
  end
end
