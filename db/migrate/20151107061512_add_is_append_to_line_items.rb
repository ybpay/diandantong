class AddIsAppendToLineItems < ActiveRecord::Migration
  def change
    add_column :ddt_line_items, :is_append, :boolean, default: false
  end
end
