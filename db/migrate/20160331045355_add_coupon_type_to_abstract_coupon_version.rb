class AddCouponTypeToAbstractCouponVersion < ActiveRecord::Migration
  def change
    add_column :ddt_abstract_coupon_versions, :coupon_type, :string
    add_column :ddt_abstract_coupon_versions, :product_name, :string
  end
end
