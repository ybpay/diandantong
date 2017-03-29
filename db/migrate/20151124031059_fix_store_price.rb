class FixStorePrice < ActiveRecord::Migration
  def change
    Ddt::Agent.with_deleted.update_all('standard_store_price=single_store_price')

    old_discount = {
      first_level: 0.15,
      second_level: 0.25,
      third_level: 0.35,
      normal_level: 0.35
    }
    Ddt::Agent.with_deleted.find_each do |agent|
      mini_store_price = Ddt::Shop::DEFAULT_MINI_PRICE * old_discount[agent.agent_type.to_sym]
      agent.update_columns(mini_store_price: mini_store_price)
    end

  end
end
