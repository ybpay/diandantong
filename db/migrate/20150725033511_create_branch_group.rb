class CreateBranchGroup < ActiveRecord::Migration
  def change
    create_table :ddt_branch_groups do |t|
      t.integer :shop_id
      t.string :name
      t.timestamps
    end

    add_index :ddt_branch_groups, :shop_id

    create_table :ddt_branches_branch_groups do |t|
      t.integer :branch_id
      t.integer :branch_group_id
      t.timestamps
    end

    add_index :ddt_branches_branch_groups, :branch_id
    add_index :ddt_branches_branch_groups, :branch_group_id

  end
end
