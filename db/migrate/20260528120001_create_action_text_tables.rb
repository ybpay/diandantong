# ActionText tables for rich text editing support.
# Replaces CKEditor rich text editing.
class CreateActionTextTables < ActiveRecord::Migration[8.1]
  def change
    create_table :action_text_rich_texts, id: :primary_key do |t|
      t.string     :name, null: false
      t.text       :body, size: :long
      t.references :record, null: false, polymorphic: true, index: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:record_type, :record_id, :name], name: :index_action_text_rich_texts_uniqueness, unique: true
    end
  end
end
