class ChangeStatisticsCacheToBinary < ActiveRecord::Migration
  def change
    change_column :ddt_statistics_caches, :result, :binary, limit: 10.megabyte
  end
end
