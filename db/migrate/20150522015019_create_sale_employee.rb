class CreateSaleEmployee < ActiveRecord::Migration
  def change
    create_table :ddt_sale_employees do |t|
      t.string :name
      t.string :phone
      t.string :qq
      t.timestamps
    end
    add_column :ddt_shops, :sale_employee_id, :integer
    add_index :ddt_shops, :sale_employee_id
    add_column :ddt_shops, :updated_sale_employee_at, :datetime
  end
end
