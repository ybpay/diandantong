class CreateItemNotesTags < ActiveRecord::Migration
  def change
    create_table :ddt_item_notes_tags do |t|
      t.references :item_note
      t.references :tag
    end
  end
end
