class AddShowOnWechatToItemNote < ActiveRecord::Migration
  def change
    add_column :ddt_item_notes, :show_on_wechat, :boolean, default: true
  end
end
