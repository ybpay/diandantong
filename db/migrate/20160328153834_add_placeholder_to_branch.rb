class AddPlaceholderToBranch < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :note_placeholder, :string, default: "整单备注：例如 饮料类加冰"
  end
end
