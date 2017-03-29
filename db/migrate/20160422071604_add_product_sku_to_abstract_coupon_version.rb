class AddProductSkuToAbstractCouponVersion < ActiveRecord::Migration
  def change
    remove_column :ddt_abstract_coupon_versions, :product_name, :string
    add_column :ddt_abstract_coupon_versions, :product_sku, :string
  end
end
