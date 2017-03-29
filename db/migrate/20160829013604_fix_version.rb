class FixVersion < ActiveRecord::Migration
  def change
    Ddt::Shop.where(shop_type: 'z1').find_each do 
      puts "------------- shop #{shop.slug}"
      recharge_type = 'z3'
      note = "系统新版本升级，升级前版本#{shop.shop_type}"
      shop.upgrade_shop_to(recharge_type, shop.max_branches_limit, shop.expiration_time, true)
      shop_recharge_record = shop.shop_recharge_records.where(recharge_type: recharge_type).first_or_initialize
      shop_recharge_record.increment_days = 0
      shop_recharge_record.branch_num = shop.max_branches_limit
      shop_recharge_record.price = 0
      shop_recharge_record.original_price = 0
      shop_recharge_record.note = note
      shop_recharge_record.save!
    end
  end
end
