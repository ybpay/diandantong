class AddOnShelfToVariant < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_variants, :on_shelf
      add_column :ddt_variants, :on_shelf, :boolean, default: true
    end
    Ddt::Variant.joins(:product).where(ddt_products: { on_shelf: false}).update_all('ddt_variants.on_shelf = 0')
  end
end
