class RemoveCostPrice < ActiveRecord::Migration
  def change
    remove_column :ddt_variants, :cost_price, :decimal, precision: 8, scale: 2
    remove_column :ddt_combos, :cost_price, :decimal, precision: 8, scale: 2
    execute <<-SQL
      ALTER TABLE ddt_line_items
        DROP cost_price,
        DROP adjustment_total;
    SQL
  end
end
