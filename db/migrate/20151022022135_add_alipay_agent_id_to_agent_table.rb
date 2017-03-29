class AddAlipayAgentIdToAgentTable < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :alipay_agent_id, :string
  end
end
