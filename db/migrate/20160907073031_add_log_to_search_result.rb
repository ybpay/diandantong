class AddLogToSearchResult < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_search_results, :log
      add_column :ddt_search_results, :log, :text
    end
  end
end
