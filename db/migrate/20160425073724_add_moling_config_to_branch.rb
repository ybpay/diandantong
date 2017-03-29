class AddMolingConfigToBranch < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :moling_type, :string, default: "moling_erase"
    add_column :ddt_branches, :moling_precision, :string, default: "moling_yuan"
    add_column :ddt_branches, :moling_auto, :boolean, default: false
  end
end
