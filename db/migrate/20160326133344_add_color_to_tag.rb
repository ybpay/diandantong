class AddColorToTag < ActiveRecord::Migration
  def change
    add_column :ddt_tags, :color, :string, default: '#f34b3f'
  end
end
