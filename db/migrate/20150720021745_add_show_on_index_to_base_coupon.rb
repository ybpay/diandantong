class AddShowOnIndexToBaseCoupon < ActiveRecord::Migration
  def change
    add_column :ddt_abstract_coupon_versions, :show_on_index, :boolean, default: false
  end
end
