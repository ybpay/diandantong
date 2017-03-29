class FixHomeHotLink2 < ActiveRecord::Migration
  def change
    add_column :ddt_home_hot_links, :is_multiple, :boolean, default: false
    Ddt::HomeHotLink.where(shop_type: ['chain', 'multiple']).update_all(:is_multiple => true)
    Ddt::HomeHotLink.where(shop_type: 'mini', label: ['签到', '券包']).delete_all
    Ddt::HomeHotLink.where(shop_type: 'chain', label: ['找餐厅', '找优惠', '找外卖']).delete_all
  end
end