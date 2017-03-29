class RemovePayMethodIsActualFromPayItems < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_pay_items, :pay_method_percent_of_actual
      add_column :ddt_pay_items, :pay_method_percent_of_actual, :integer, default: 100
    end
    Ddt::PayItem.where(pay_method_is_actual: false).update_all(pay_method_percent_of_actual: 0)

  end
end
