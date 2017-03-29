class FixAgentDataAgain < ActiveRecord::Migration
  def change
    Ddt::Agent.with_deleted.update_all('chain_start_price = single_store_price + increase_per_store_cost')
  end
end
