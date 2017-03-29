class AddQqToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :qq, :string
  end
end
