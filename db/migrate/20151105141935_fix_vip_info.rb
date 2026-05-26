class FixVipInfo < ActiveRecord::Migration
  def change
    vips = Ddt::VipInfo.find_by_sql(%Q{
      select * from
      (select v.id, v.base_users_count as v_count, count(u.id) as u_count
        from ddt_vip_infos as v
        INNER JOIN ddt_base_users AS u ON v.id = u.vip_info_id
        group by v.id, v.base_users_count) as result
      where v_count != u_count
    })
    vips.each do |v|
      Ddt::VipInfo.with_deleted.reset_counters(v.id, :base_users)
    end
  end
end
