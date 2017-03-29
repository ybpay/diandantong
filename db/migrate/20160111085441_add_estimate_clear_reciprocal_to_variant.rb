class AddEstimateClearReciprocalToVariant < ActiveRecord::Migration
  def change
    puts "column estimate_clear_reciprocal -----ing"
    add_column :ddt_variants , :estimate_clear_reciprocal , :boolean , default: false
  end
end
