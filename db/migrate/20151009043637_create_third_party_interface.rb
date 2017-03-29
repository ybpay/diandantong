class CreateThirdPartyInterface < ActiveRecord::Migration
  def change
    create_table :ddt_keywords_third_party_interfaces do |t|
      t.references :wechat_account
      t.string :keywords
      t.string :api
      t.string :match_type
      t.string :token
      t.boolean :opened, default: false
      t.timestamps
    end
    add_index :ddt_keywords_third_party_interfaces, :wechat_account_id, name: "index_ddt_ktpi_wechat_account_id"
  end
end
