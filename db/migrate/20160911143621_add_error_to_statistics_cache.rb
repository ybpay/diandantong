class AddErrorToStatisticsCache < ActiveRecord::Migration
  def change
    add_column :ddt_statistics_caches, :label, :string unless column_exists? :ddt_statistics_caches, :label
    add_column :ddt_statistics_caches, :query, :text unless column_exists? :ddt_statistics_caches, :query
    add_column :ddt_statistics_caches, :progress, :integer unless column_exists? :ddt_statistics_caches, :progress
    add_index :ddt_statistics_caches, :label unless index_exists? :ddt_statistics_caches, :label
    remove_index :ddt_statistics_caches, column: :name if index_exists? :ddt_statistics_caches, :name
  end
end
