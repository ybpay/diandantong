class AddOperatorNameToOrderChangeLog < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_order_change_logs, :operator_name
      add_column :ddt_order_change_logs, :operator_name, :string
    end
  end
end
