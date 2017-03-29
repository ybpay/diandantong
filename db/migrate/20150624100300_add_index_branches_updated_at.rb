class AddIndexBranchesUpdatedAt < ActiveRecord::Migration
  def change
    add_index :ddt_branches, [:updated_at]
  end
end
