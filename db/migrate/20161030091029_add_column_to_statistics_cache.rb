class AddColumnToStatisticsCache < ActiveRecord::Migration
  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection = ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def change
    with_proper_connection do
      ActiveRecord::Migration.add_column :ddt_statistics_caches, :csv, :string
      ActiveRecord::Migration.add_column :ddt_statistics_caches, :xls, :string
    end
  end
end
