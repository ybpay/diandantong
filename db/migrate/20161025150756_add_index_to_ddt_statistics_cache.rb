class AddIndexToDdtStatisticsCache < ActiveRecord::Migration
  def change
    add_index :ddt_statistics_caches, :created_at
  end
end
