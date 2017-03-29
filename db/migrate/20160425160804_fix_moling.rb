class FixMoling < ActiveRecord::Migration
  def change
    change_column :ddt_branches, :moling_type, :string, default: "moling_round"
    change_column :ddt_branches, :moling_auto, :boolean, default: true
    Ddt::Branch.update_all("moling_type = 'moling_round'")
    Ddt::Branch.update_all("moling_auto = true")
  end
end
