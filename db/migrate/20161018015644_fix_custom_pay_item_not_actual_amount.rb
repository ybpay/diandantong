class FixCustomPayItemNotActualAmount < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE ddt_pay_items SET not_actual_amount = amount * (100 - pay_method_percent_of_actual) / 100
      WHERE deleted_at IS NOT NULL
      AND state = 'paid'
      AND pay_method_name_sym IS NULL
      AND amount * (100 - pay_method_percent_of_actual) / 100 != not_actual_amount
    SQL
  end
end
