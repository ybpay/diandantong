class CreatePreSaleStaff < ActiveRecord::Migration
  def change
    create_table :ddt_pre_sale_staffs do |t|
      t.string :name
      t.string :phone
      t.string :qq
      t.string :email
      t.timestamps
    end
    add_column :ddt_shops, :pre_sale_staff_id, :integer
    add_index :ddt_shops, :pre_sale_staff_id
    add_column :ddt_shops, :updated_pre_sale_staff_at, :datetime
  end
end
