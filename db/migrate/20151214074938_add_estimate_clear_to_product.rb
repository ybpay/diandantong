class AddEstimateClearToProduct < ActiveRecord::Migration
  def change
    add_column :ddt_products, :estimate_clear ,:boolean, default:false
    Ddt::Product.where(on_shelf: false).update_all(estimate_clear: true)
  end
end
