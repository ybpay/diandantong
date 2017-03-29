class RemoveIsOpenFromBranch < ActiveRecord::Migration
  def change
    remove_column :ddt_branches, :is_open
  end
end
