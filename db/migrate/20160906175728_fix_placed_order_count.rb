class FixPlacedOrderCount < ActiveRecord::Migration
  def change
    #execute "UPDATE ddt_base_users SET placed_orders_count = 0"
    unless column_exists? :ddt_vip_infos, :placed_orders_count
      add_column :ddt_vip_infos, :placed_orders_count, :integer, default: 0
    else
      execute <<-SQL
        UPDATE ddt_vip_infos set placed_orders_count = 0
      SQL
    end
    fix_vip_info_id_nil
    fill_placed_orders_count
  end

  def fix_vip_info_id_nil
    execute <<-SQL
      UPDATE ddt_orders as o
      INNER JOIN ddt_base_users as u ON u.id = o.base_user_id
      SET o.vip_info_id = u.vip_info_id
      WHERE o.base_user_id IS NOT NULL
        AND o.vip_info_id IS NULL
        AND o.placed_at IS NOT NULL
    SQL

    execute <<-SQL
      UPDATE ddt_orders as o
        INNER JOIN ddt_base_users as u ON u.id = o.base_user_id
        SET o.vip_info_id = u.vip_info_id
        WHERE o.vip_info_id = u.original_vip_info_id
          AND o.placed_at IS NOT NULL
    SQL
  end

  def fill_placed_orders_count
    execute <<-SQL
      UPDATE ddt_orders as o
      INNER JOIN  ddt_vip_infos as v on v.id = o.vip_info_id
      SET `placed_orders_count` = `placed_orders_count` + 1
      WHERE o.placed_at IS NOT NULL
    SQL
  end


end
