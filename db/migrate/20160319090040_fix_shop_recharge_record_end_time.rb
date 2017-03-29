class FixShopRechargeRecordEndTime < ActiveRecord::Migration
  def up
    change_column :ddt_shop_recharge_records, :beginning_time, :datetime,  null: false
    change_column :ddt_shop_recharge_records, :increment_days, :integer, null: false
    change_column :ddt_shop_recharge_records, :ending_time, :datetime,  null: false

    #5211 5213 5302
    Ddt::Shop.find_each do |shop|
        if !shop.expired? && shop.shop_recharge_records.count > 0
            shop_recharge_record = shop.shop_recharge_records.where("increment_days != 0").order("created_at desc").first
            if shop_recharge_record.created_at + (shop_recharge_record.increment_days+7).days + 13.seconds < shop_recharge_record.ending_time
                puts "#{shop_recharge_record.shop_id}: #{shop_recharge_record.id}: #{shop_recharge_record.ending_time} != #{shop_recharge_record.created_at} + #{shop_recharge_record.increment_days}days"
                beginning_time = shop_recharge_record.created_at
                ending_time = shop_recharge_record.created_at + shop_recharge_record.increment_days.days
                shop_recharge_record.update_attributes({beginning_time: beginning_time, ending_time: ending_time})
                shop.update_attribute(:expiration_time, ending_time)
            end
        end
    end
  end

  def down
  end
end
