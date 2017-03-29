class RemoveDeletedPhoneUser < ActiveRecord::Migration
  def up
    sql = <<-SQL
      update ddt_base_users u
      inner join ddt_vip_infos as v on v.id = u.vip_info_id
      set u.deleted_at = v.deleted_at
      where
        v.deleted_at is not null and u.type = "Ddt::PhoneUser";
    SQL
    execute(sql)
  end

  def down

  end
end
