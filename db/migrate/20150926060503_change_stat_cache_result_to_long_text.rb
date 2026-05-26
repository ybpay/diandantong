class ChangeStatCacheResultToLongText < ActiveRecord::Migration
  def change
    change_column :ddt_statistics_caches, :result, :text
  end
end
