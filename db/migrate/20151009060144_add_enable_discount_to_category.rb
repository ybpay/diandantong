class AddEnableDiscountToCategory < ActiveRecord::Migration
  def change
    add_column :ddt_categories, :enable_discount, :boolean, default: true
  end
end
