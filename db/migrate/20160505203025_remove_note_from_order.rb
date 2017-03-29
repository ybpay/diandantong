class RemoveNoteFromOrder < ActiveRecord::Migration
  def change
    if column_exists? :ddt_orders, :note
      remove_column :ddt_orders, :note
    end
  end
end
