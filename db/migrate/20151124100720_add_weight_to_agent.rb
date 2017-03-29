class AddWeightToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :weight, :integer, default: 100
  end
end
