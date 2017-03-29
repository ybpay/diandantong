class AddCanExchangeToAbstractCouponVersion < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_abstract_coupon_versions, :can_exchange
      add_column :ddt_abstract_coupon_versions, :can_exchange, :boolean, default: false
      add_column :ddt_abstract_coupon_versions, :credit_count, :integer, default: 10000
    end
  end
end
