class AddPhoneToShop < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shops, :phone
      add_column :ddt_shops, :phone, :string
      count = 0
      Ddt::Account.where(built_in: true).find_each do |account|
        count += 1
        puts "Copy built_in account(id: #{account.id}) phone to shop" if count % 100 == 0
        account.shop.update_column(:phone, account.phone)
      end
    end
  end
end
