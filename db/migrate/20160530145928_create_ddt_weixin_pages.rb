class CreateDdtWeixinPages < ActiveRecord::Migration
  def change
    create_table :ddt_weixin_pages do |t|
      t.references :shop, index: true
      t.string :url
      t.string :template_type

      t.timestamps
    end
  end
end
