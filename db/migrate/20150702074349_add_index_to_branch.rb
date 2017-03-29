class AddIndexToBranch < ActiveRecord::Migration
  def change
    add_index :ddt_branches, :position
  end
end
