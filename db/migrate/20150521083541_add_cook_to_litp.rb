class AddCookToLitp < ActiveRecord::Migration
  def change
    table_name = :ddt_line_item_trace_points
    unless column_exists? table_name, :cook_id
      add_column table_name, :cook_id, :integer
    end
  end
end
