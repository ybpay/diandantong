class AddSomeColumnsToBaseCoupon < ActiveRecord::Migration
  def change
    add_column :ddt_base_coupons, :usable_starts_at, :datetime
    add_column :ddt_base_coupons, :usable_expires_at, :datetime
  end
end
