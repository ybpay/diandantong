class CreateWebposBanProducts < ActiveRecord::Migration
  def change
    create_table :ddt_webpos_ban_products, id: false do |t|
      t.references :table_zone, index: true
      t.references :product, index: true
    end
  end
end
