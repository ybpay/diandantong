class AddByWeightToVariants < ActiveRecord::Migration
  def change
    add_column :ddt_variants, :by_weight, :boolean, default: false
  end
end
