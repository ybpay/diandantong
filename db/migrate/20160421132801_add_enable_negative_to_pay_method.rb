class AddEnableNegativeToPayMethod < ActiveRecord::Migration
  def change
    add_column :ddt_pay_methods, :enable_negative, :boolean, default: false
  end
end
