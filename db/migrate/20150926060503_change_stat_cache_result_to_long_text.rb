class ChangeStatCacheResultToLongText < ActiveRecord::Migration
  def change
    change_column :ddt_statistics_caches, :result, :longtext
  end
end
