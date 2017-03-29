class RemoveBranchTypeIdFromTag < ActiveRecord::Migration
  def change
    if column_exists? :ddt_tags, :branch_type_id
      remove_column :ddt_tags, :branch_type_id
    end
  end
end
