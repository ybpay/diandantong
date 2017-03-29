class AddNoteToLitp < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_line_item_trace_points, :note
      add_column :ddt_line_item_trace_points, :note, :string
    end
  end
end
