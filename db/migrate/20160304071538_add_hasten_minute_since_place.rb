class AddHastenMinuteSincePlace < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_branches, :hasten_minute_since_place
      add_column :ddt_branches, :hasten_minute_since_place, :integer, default: 0
    end
  end
end
