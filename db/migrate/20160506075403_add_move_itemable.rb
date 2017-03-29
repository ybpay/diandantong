class AddMoveItemable < ActiveRecord::Migration
  def up
    add_column :ddt_line_items, :is_from_move, :boolean, default: false unless column_exists? :ddt_line_items, :is_from_move
    add_column :ddt_line_items, :is_moved, :boolean, default: false unless column_exists? :ddt_line_items, :is_moved
    add_column :ddt_line_items, :move_quantity, :integer, default: 0 unless column_exists? :ddt_line_items, :move_quantity
  end

  def down
    remove_column :ddt_line_items, :is_from_move, :boolean, default: false if column_exists? :ddt_line_items, :is_from_move
    remove_column :ddt_line_items, :is_moved, :boolean, default: false if column_exists? :ddt_line_items, :is_moved
    remove_column :ddt_line_items, :move_quantity, :integer, default: 0 if column_exists? :ddt_line_items, :move_quantity
  end
end
