class RemoveDeletedStCache < ActiveRecord::Migration
  def change
    Ddt::StatisticsCache.where(shop_id: nil).delete_all
  end
end
