class AddColumnToStatisticsCache < ActiveRecord::Migration
  def change
    add_column :ddt_statistics_caches, :csv, :string
    add_column :ddt_statistics_caches, :xls, :string
  end
end
