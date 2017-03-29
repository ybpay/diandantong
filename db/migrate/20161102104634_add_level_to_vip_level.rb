class AddLevelToVipLevel < ActiveRecord::Migration
  def change
    if !column_exists? :ddt_vip_levels, :level
      add_column :ddt_vip_levels, :level, :integer, default: 0
    end

    execute "set @pre_shop_id = 0"
    execute "set @pre_level = 0"
    execute <<-SQL
      UPDATE ddt_vip_levels
      SET level = IF(is_default = 1,
        IF(@pre_shop_id != shop_id, (@pre_shop_id := shop_id) && @pre_level := 0, 0),
        IF(@pre_shop_id != shop_id, (@pre_shop_id := shop_id) && @pre_level := 1, @pre_level := @pre_level + 1)
      )
      ORDER BY shop_id, discount desc, id asc;
    SQL

=begin
    if is_default
      if pre_shop_id != shop_id
        pre_shop_id = shop_id
        pre_level = 0
        0
      else
        0
      end
    else
      if pre_shop_id != shop_id
        pre_shop_id = shop_id
        pre_level = 1
      else
        pre_level = pre_level + 1
      end
    end
=end
  end
end
