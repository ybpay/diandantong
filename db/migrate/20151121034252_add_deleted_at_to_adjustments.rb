class AddDeletedAtToAdjustments < ActiveRecord::Migration
  def change
    add_column :ddt_adjustments, :deleted_at, :datetime
  end
end
