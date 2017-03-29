class CreateCreditsSetting < ActiveRecord::Migration
  def change
    create_table :ddt_credits_settings do |t|
      t.references :shop, index: true
      t.integer :exchange_radio, default: 100
      t.timestamps
    end
    Ddt::Shop.all.find_each do |shop|
      shop.create_credits_setting
    end
  end
end
