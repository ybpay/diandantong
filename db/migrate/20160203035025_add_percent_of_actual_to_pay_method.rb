class AddPercentOfActualToPayMethod < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_pay_methods, :percent_of_actual
      add_column :ddt_pay_methods, :percent_of_actual, :integer, default: 100
    end
  end
end
