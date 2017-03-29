class AddLogoToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :logo, :string
    add_column :ddt_agents, :rect_logo, :string
  end
end
