class FixForceOnLine < ActiveRecord::Migration
  def change
    change_column :ddt_cs_branch_bindings, :force_online, :boolean, default: false
    change_column :ddt_cs_branch_bindings, :online, :boolean, default: false
  end
end
