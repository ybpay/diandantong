class AddShowOnWechatToProduct < ActiveRecord::Migration
  def change
    add_column :ddt_products, :show_on_wechat, :boolean, default: true
    add_column :ddt_combos, :show_on_wechat, :boolean, default: true
  end
end
