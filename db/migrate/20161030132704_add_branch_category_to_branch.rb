class AddBranchCategoryToBranch < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :branch_category, :string, default: 'others'
  end
end
