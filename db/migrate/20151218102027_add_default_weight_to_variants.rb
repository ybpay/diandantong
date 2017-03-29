class AddDefaultWeightToVariants < ActiveRecord::Migration
  def change
    add_column :ddt_variants, :default_weight, :float, default: 1.0
  end
end
