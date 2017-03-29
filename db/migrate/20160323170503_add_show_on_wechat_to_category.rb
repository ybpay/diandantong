class AddShowOnWechatToCategory < ActiveRecord::Migration
  def change
    unless  column_exists? :ddt_categories, :show_on_wechat
      add_column :ddt_categories, :show_on_wechat, :boolean, default: true
    end
  end
end
