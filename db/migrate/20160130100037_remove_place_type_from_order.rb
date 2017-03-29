class RemovePlaceTypeFromOrder < ActiveRecord::Migration
  def change
    if column_exists? :ddt_orders, :place_type
      remove_column :ddt_orders, :place_type
    end
  end
end
