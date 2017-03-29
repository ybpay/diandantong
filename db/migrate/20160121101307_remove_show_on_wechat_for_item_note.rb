class RemoveShowOnWechatForItemNote < ActiveRecord::Migration
  def change
    if column_exists? :ddt_item_notes, :show_on_wechat
      remove_column :ddt_item_notes, :show_on_wechat
    end
  end
end
