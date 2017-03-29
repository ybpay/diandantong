class AddGiftToLineItem < ActiveRecord::Migration
  def change
    add_column :ddt_line_items, :gift, :boolean, default: false
  end
end
