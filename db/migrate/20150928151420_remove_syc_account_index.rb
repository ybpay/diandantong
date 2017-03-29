class RemoveSycAccountIndex < ActiveRecord::Migration
  def change
  	remove_index :ddt_app_notification_caches, :name => :anc_account
  end
end
