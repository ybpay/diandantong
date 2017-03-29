class AddUserIdToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :user_id, :integer
  end
end
