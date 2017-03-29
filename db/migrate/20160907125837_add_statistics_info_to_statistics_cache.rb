class AddStatisticsInfoToStatisticsCache < ActiveRecord::Migration

  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection = ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def change
    with_proper_connection do
      Ddt::StatisticsCache.delete_all
      # ActiveRecord::Migration.add_column :ddt_statistics_caches, :name, :string
      # ActiveRecord::Migration.add_column :ddt_statistics_caches, :url, :text
      # ActiveRecord::Migration.add_column :ddt_statistics_caches, :shop_id, :integer
      # ActiveRecord::Migration.add_index :ddt_statistics_caches, :name
      # ActiveRecord::Migration.add_index :ddt_statistics_caches, :shop_id
      # ActiveRecord::Migration.add_index :ddt_statistics_caches, :updated_at
    end
  end
end
