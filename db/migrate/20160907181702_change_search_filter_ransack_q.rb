class ChangeSearchFilterRansackQ < ActiveRecord::Migration
  def change
    change_column :ddt_search_filters, :ransack_q, :text
  end
end
