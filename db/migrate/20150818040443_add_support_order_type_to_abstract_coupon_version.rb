class AddSupportOrderTypeToAbstractCouponVersion < ActiveRecord::Migration
  def change
    add_column :ddt_abstract_coupon_versions, :support_delivery, :boolean, default: true
    add_column :ddt_abstract_coupon_versions, :support_eat_in_hall, :boolean, default: true
  end
end
