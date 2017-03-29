class AddCardKeyToShop < ActiveRecord::Migration
  def change
  	unless column_exists? :ddt_shops, :card_key
    	add_column :ddt_shops, :card_key, :string
    end
    Ddt::Shop.all.find_each do |shop|
      Ddt::ShopInitializer.new(shop).create_card_key!
    end
  end
end
