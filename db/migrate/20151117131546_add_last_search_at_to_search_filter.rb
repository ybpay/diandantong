class AddLastSearchAtToSearchFilter < ActiveRecord::Migration
  def change
    add_column :ddt_search_filters, :last_search_at, :datetime
  end
end
