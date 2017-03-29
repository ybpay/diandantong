class AddEstimateClearToVariant < ActiveRecord::Migration
  def change
    add_column :ddt_variants, :estimate_clear ,:boolean ,default: false
    Ddt::Variant.where(on_shelf: false).update_all(estimate_clear: true)
  end
end
