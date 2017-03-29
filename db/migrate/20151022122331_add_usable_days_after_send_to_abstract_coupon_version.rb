class AddUsableDaysAfterSendToAbstractCouponVersion < ActiveRecord::Migration
  def change
    add_column :ddt_abstract_coupon_versions, :usable_days_after_send, :integer
  end
end
