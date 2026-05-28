class AddStatisticsInfoToStatisticsCache < ActiveRecord::Migration
  def change
    Ddt::StatisticsCache.delete_all
  end
end
