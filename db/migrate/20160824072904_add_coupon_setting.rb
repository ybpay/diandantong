class AddCouponSetting < ActiveRecord::Migration
  def change
    create_table :ddt_coupon_settings do |t|
      t.references :shop, index: true
      t.boolean :enable_expired_notify
      t.integer :expired_notify_in_advance_days, default: 1
      t.timestamps
    end

    Ddt::Shop.all.find_each do |shop|
      shop.create_coupon_setting
    end
  end
end
