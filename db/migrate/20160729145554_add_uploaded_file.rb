class AddUploadedFile < ActiveRecord::Migration
  def change
    create_table :ddt_uploaded_files do |t|
      t.references :shop, index: true
      t.string :file
      t.timestamps
    end
  end
end
