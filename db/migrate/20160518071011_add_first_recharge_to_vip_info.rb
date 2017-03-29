class AddFirstRechargeToVipInfo < ActiveRecord::Migration
  def up
    add_column :ddt_vip_infos, :first_recharge_at, :datetime
    add_column :ddt_vip_infos, :first_recharge_limited_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_recharge_products, :first_recharge_available_amount, :decimal, precision: 8, scale: 2, default: 100.0
    execute <<-SQL
      update ddt_recharge_products rp
      set rp.first_recharge_available_amount = rp.recharge_amount;
    SQL
  end

  def down
    remove_column :ddt_vip_infos, :first_recharge_at, :datetime
    remove_column :ddt_vip_infos, :first_recharge_limited_amount, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_recharge_products, :first_recharge_available_amount, :decimal, precision: 8, scale: 2, default: 100.0
  end
end
