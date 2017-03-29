class AddWechatShareRecordIdToPromotionEvent < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_promotion_events, :wechat_share_record_id
      add_column :ddt_promotion_events, :wechat_share_record_id, :integer
      add_index :ddt_promotion_events, :wechat_share_record_id
    end
  end
end
