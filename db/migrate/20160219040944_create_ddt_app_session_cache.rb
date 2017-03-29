class CreateDdtAppSessionCache < ActiveRecord::Migration
  def change
    create_table :ddt_app_session_caches do |t|
      t.integer :account_id
      t.text :cache
    end
    add_index :ddt_app_session_caches, :account_id
  end
end
