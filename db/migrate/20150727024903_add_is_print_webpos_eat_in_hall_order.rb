class AddIsPrintWebposEatInHallOrder < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_print_settings, :is_webpos_print_eatinhall_order_when_place
      add_column :ddt_print_settings, :is_webpos_print_eatinhall_order_when_place, :boolean, default: true
    end
  end
end
