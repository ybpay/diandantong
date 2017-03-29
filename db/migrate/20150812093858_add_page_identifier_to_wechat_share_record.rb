class AddPageIdentifierToWechatShareRecord < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_wechat_share_records, :page_identifier
      add_column :ddt_wechat_share_records, :page_identifier, :string
    end
  end
end
