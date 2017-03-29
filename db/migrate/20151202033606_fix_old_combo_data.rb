class FixOldComboData < ActiveRecord::Migration
  def change
    Ddt::Combo.find_each do |combo|
      combo_items = combo.combo_items
      if combo_items.size > 0
        item = combo_items[0].update_columns(price: combo.price, vip_price: combo.vip_price)
      end
    end
  end
end
