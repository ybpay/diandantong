class CreateItemNoteProduct < ActiveRecord::Migration
  def change
    create_table :ddt_item_notes_products, id: false do |t|
      t.references :item_note
      t.references :product
    end
  end
end
