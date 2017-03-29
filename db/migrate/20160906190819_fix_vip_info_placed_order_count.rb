class FixVipInfoPlacedOrderCount < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE ddt_vip_infos as v
      SET placed_orders_count = (
        select count(id) 
        from ddt_orders  as o
        where v.id = o.vip_info_id 
        and o.placed_at IS NOT NULL);
    SQL
    
  end
end
