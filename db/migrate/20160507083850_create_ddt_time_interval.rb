class CreateDdtTimeInterval < ActiveRecord::Migration
  def change
    create_table :ddt_time_intervals do |t|
      t.integer :shop_id
      t.string :name
      t.time :start
      t.integer :interval
    end
    add_index :ddt_time_intervals, :shop_id
  end
end
