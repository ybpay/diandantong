class AddOriginalPriceToShopRechargeRecord < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shop_recharge_records, :original_price
      add_column :ddt_shop_recharge_records, :original_price, :decimal, precision: 10, scale: 2
    end
    Ddt::ShopRechargeRecord.find_each do|shop_recharge_record|
      shop_recharge_record.update_column(:original_price, shop_recharge_record.price) if shop_recharge_record.original_price.nil? or shop_recharge_record.original_price <= 0
    end
  end
end
