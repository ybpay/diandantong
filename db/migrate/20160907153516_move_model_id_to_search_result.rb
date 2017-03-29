class MoveModelIdToSearchResult < ActiveRecord::Migration
  def change
    add_column :ddt_search_results, :model_ids_str, :text
    drop_table :ddt_search_details
  end
end
