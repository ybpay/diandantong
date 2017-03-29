class AddNoteToLineItem < ActiveRecord::Migration
  def change
    add_column :ddt_line_items, :note, :string
    create_table :ddt_item_notes do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.string :name
      t.timestamps
    end
  end
end
