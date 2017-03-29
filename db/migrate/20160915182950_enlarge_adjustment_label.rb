class EnlargeAdjustmentLabel < ActiveRecord::Migration
  def change
    change_column :ddt_adjustments, :label, :text
  end
end
