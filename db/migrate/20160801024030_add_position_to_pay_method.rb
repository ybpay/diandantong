class AddPositionToPayMethod < ActiveRecord::Migration
  def change
    add_column :ddt_pay_methods, :position, :integer unless column_exists? :ddt_pay_methods, :position
    Ddt::Shop.all.find_each do |shop|
      shop.pay_methods.each_with_index do |pay_method, index|
        pay_method.update_column(:position, index + 1)
      end
    end
  end
end
