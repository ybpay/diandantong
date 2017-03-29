class AddColumnsToDdtStatisticsCache < ActiveRecord::Migration
  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection = ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end
  def change
    with_proper_connection do
      ActiveRecord::Migration.add_column :ddt_statistics_caches, :operator_id, :integer
      ActiveRecord::Migration.add_column :ddt_statistics_caches, :cost_time, :decimal, precision: 8, scale: 2
    end
  end
end
