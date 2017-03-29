class AddOperatorIdToAdjustment < ActiveRecord::Migration
  def change
  	add_column :ddt_adjustments, :operator_id, :integer 
  	add_column :ddt_adjustments, :authorizer_id, :integer
  end
end
