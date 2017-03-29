class AddPositionToProduct < ActiveRecord::Migration
  def change
    if !column_exists? :ddt_products, :position
      add_column :ddt_products, :position, :integer, null: false, default: 10
    end
  end
end
