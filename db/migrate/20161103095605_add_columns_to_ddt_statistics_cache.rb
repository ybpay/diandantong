class AddColumnsToDdtStatisticsCache < ActiveRecord::Migration
  def change
    add_column :ddt_statistics_caches, :operator_id, :integer
    add_column :ddt_statistics_caches, :cost_time, :decimal, precision: 8, scale: 2
  end
end
