class CreateDdtApiKeys < ActiveRecord::Migration
  def change
    create_table :ddt_api_keys do |t|
      t.string :name
      t.string :access_token

      t.timestamps
    end
  end
end
