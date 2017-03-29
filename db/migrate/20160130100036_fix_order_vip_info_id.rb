class FixOrderVipInfoId < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE ddt_orders AS o
      LEFT JOIN ddt_base_users AS u ON o.base_user_id = u.id
      SET o.vip_info_id = u.vip_info_id
      WHERE o.state != 'cart' AND o.base_user_id IS NOT NULL
    SQL
  end
end
