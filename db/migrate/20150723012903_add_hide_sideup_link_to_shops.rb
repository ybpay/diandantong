class AddHideSideupLinkToShops < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shops, :is_hide_signup_link
      add_column :ddt_shops, :is_hide_signup_link, :boolean, default: false
    end
  end
end
