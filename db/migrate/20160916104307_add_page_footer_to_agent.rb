class AddPageFooterToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :page_footer, :string
  end
end
