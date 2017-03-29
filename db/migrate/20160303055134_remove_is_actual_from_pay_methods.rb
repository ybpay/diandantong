class RemoveIsActualFromPayMethods < ActiveRecord::Migration
  def change
    if column_exists? :ddt_pay_methods, :is_actual
      remove_column :ddt_pay_methods, :is_actual
    end

    if column_exists? :ddt_shift_items, :pay_method_is_actual
        # remove pay_method_is_actual
        remove_column :ddt_shift_items, :pay_method_is_actual
    end
    
    if column_exists? :ddt_pay_items, :pay_method_is_actual
      remove_column :ddt_pay_items, :pay_method_is_actual
    end
  end
end
