class AddIndexToDdtStatisticsCache < ActiveRecord::Migration
  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection = ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def change
    with_proper_connection do
      ActiveRecord::Migration.add_index :ddt_statistics_caches, :created_at
    end
  end
end
