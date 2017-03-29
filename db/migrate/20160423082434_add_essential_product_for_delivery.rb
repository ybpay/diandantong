class AddEssentialProductForDelivery < ActiveRecord::Migration
  def change
    add_column :ddt_essential_products, :order_type, :string, default: "eat_in_hall"
  end
end
