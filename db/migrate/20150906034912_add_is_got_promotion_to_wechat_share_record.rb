class AddIsGotPromotionToWechatShareRecord < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_wechat_share_records, :is_got_promotion
      add_column :ddt_wechat_share_records, :is_got_promotion, :boolean, default: false
    end
  end
end
