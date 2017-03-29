class AddDiscountToAgent < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_agents, :discount
      add_column :ddt_agents, :discount, :decimal, precision: 5, scale: 2, default: 1.0
    end
    Ddt::Agent.find_each do |agent|
      discount = (agent.standard_store_price.to_f/8680)
      if agent.standard_store_price < 1000 || discount < 0.1
        discount = (agent.standard_store_price.to_f/2880).round(2)
      end
      puts "agent price is #{agent.standard_store_price} / 8680 = #{discount}"
      agent.discount = discount
      agent.save!
    end
  end
end
