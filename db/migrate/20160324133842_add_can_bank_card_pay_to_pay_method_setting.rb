class AddCanBankCardPayToPayMethodSetting < ActiveRecord::Migration
  def change
    add_column :ddt_pay_method_settings, :can_bank_card_pay, :boolean, :default => false
  end
end
