class AddBranchNumToLisences < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_lisences, :branch_num
      add_column :ddt_lisences, :branch_num, :integer, default: 1
    end
  end
end
