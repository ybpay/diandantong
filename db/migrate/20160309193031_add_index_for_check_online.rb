class AddIndexForCheckOnline < ActiveRecord::Migration
  def change
    add_index :ddt_cs_branch_bindings, :updated_at
  end
end
