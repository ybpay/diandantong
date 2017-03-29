class AddDeletedAtToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :deleted_at, :datetime
  end
end
