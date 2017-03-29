class CreatePage < ActiveRecord::Migration
  def change
    create_table :ddt_pages do |t|
      t.references :shop, index: true
      t.references :wechat_account, index: true
      t.integer :page_id
      t.string :title
      t.string :description
      t.string :page_url
      t.string :comment
      t.string :icon_url
      t.timestamps
    end
    add_index :ddt_pages, :page_id
  end
end
