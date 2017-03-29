class RemoveWeightFromAgent < ActiveRecord::Migration
  def change
    remove_column :ddt_agents, :weight
  end
end
