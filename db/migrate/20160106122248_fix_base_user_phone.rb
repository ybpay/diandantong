class FixBaseUserPhone < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE ddt_base_users as u
      LEFT JOIN ddt_vip_infos as v ON u.vip_info_id = v.id
      SET u.phone = v.phone
      WHERE v.phone IS NOT NULL and (u.phone IS NULL OR u.phone = '')
    SQL
  end
end
