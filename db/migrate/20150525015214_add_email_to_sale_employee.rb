class AddEmailToSaleEmployee < ActiveRecord::Migration
  def change
    add_column :ddt_sale_employees, :email, :string
  end
end
