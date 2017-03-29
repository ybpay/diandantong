class AddCanVipCardPayToPayMethodSetting < ActiveRecord::Migration
  def change
    add_column :ddt_pay_method_settings, :can_vip_card_pay, :boolean, :default => true
  end
end
