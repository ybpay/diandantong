class AddConsumeTimesToVipInfo < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_vip_infos, :consume_times
      add_column :ddt_vip_infos, :consume_times, :integer, default: 0
    end

    execute <<-SQL
      UPDATE ddt_vip_infos as v
      SET consume_times = (
        select count(id) 
        from ddt_orders  as o
        where v.id = o.vip_info_id 
        and o.state = 'completed');
    SQL
  end
end
