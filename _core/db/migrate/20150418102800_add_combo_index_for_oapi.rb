class AddComboIndexForOapi < ActiveRecord::Migration
  def change
    add_index :ddt_combos, :updated_at
  end
end
