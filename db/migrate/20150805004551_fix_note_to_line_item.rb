class FixNoteToLineItem < ActiveRecord::Migration
  def change
    change_column :ddt_line_items, :note, :string, default: ''
    execute "UPDATE ddt_line_items l SET l.note = '' WHERE l.note is null;"
  end
end
