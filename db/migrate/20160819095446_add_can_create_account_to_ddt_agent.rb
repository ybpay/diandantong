class AddCanCreateAccountToDdtAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :can_create_account, :boolean, default: false
  end
end
