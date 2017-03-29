class CreateGiftReason < ActiveRecord::Migration
  def change
    create_table :ddt_gift_reasons do |t|
      t.references :shop
      t.string :name
      t.timestamps
    end
  end
end
