class AddShopsCountToSaleEmployee < ActiveRecord::Migration
  def change
  	unless column_exists? :ddt_sale_employees, :shops_count
  		add_column :ddt_sale_employees, :shops_count, :integer, default: 0
  	end
  	# Ddt::SaleEmployee.find_each do |saler|
  	# 	Ddt::SaleEmployee.reset_counters(saler.id, :shops)
  	# end
  end
end
