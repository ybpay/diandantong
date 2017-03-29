class AddPhoneAddressToAccount < ActiveRecord::Migration
  def change
    add_column :ddt_accounts, :phone_address, :string
  end
end
