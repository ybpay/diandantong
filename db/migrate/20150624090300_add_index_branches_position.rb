class AddIndexBranchesPosition < ActiveRecord::Migration
  def change
    add_index :ddt_branches, [:shop_id, :position]
  end
end
