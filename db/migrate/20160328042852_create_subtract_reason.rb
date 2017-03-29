class CreateSubtractReason < ActiveRecord::Migration
  def change
    create_table :ddt_subtract_reasons do |t|
      t.references :shop
      t.string :name
      t.timestamps
    end
  end
end
