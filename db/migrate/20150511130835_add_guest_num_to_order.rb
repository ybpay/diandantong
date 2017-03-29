class AddGuestNumToOrder < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_orders, :guest_num
      add_column :ddt_orders, :guest_num, :integer
    end
    unless column_exists? :ddt_tables, :guest_num
      add_column :ddt_tables, :guest_num, :integer
    end
  end
end
