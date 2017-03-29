class AddEndAtToCombo < ActiveRecord::Migration
  def change
    add_column :ddt_combos, :end_at, :datetime
  end
end
