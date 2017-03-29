class AddErrorToStatisticsCache < ActiveRecord::Migration
  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection = ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def change
    with_proper_connection do
      ActiveRecord::Migration.add_column :ddt_statistics_caches, :label, :string unless ActiveRecord::Migration.column_exists? :ddt_statistics_caches, :label
      ActiveRecord::Migration.add_column :ddt_statistics_caches, :query, :text unless ActiveRecord::Migration.column_exists? :ddt_statistics_caches, :query
      ActiveRecord::Migration.add_column :ddt_statistics_caches, :progress, :integer unless ActiveRecord::Migration.column_exists? :ddt_statistics_caches, :progress
      ActiveRecord::Migration.add_index :ddt_statistics_caches, :label unless ActiveRecord::Migration.index_exists? :ddt_statistics_caches, :label
      ActiveRecord::Migration.remove_index :ddt_statistics_caches, column: :name if ActiveRecord::Migration.index_exists? :ddt_statistics_caches, :name
    end
  end
end
