class AddSaleEmployeeIdToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :sale_employee_id, :integer
    add_column :ddt_agents, :updated_sale_employee_at, :datetime
    add_index  :ddt_agents, :sale_employee_id
    remove_column :ddt_sale_employees, :shops_count, :integer
  end
end
