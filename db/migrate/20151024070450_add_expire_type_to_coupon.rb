class AddExpireTypeToCoupon < ActiveRecord::Migration
  def change
    add_column :ddt_abstract_coupon_versions, :expired_type, :string, default: "fixed_expired_time"
  end
end
