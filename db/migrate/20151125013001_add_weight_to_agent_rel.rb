class AddWeightToAgentRel < ActiveRecord::Migration
  def change
    add_column :ddt_agent_rels, :weight, :integer, default: 100
  end
end
