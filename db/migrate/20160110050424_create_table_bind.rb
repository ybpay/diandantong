class CreateTableBind < ActiveRecord::Migration
  def change
    create_table :ddt_table_binds do |t|
      t.references :shop
      t.references :branch
      t.integer :active_table_id
    end
  end
end
