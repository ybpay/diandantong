class CreateBranchesTag < ActiveRecord::Migration
  def change
    create_table :ddt_branches_tags do |t|
      t.references :branch, index: true
      t.references :tag, index: true
    end
  end
end
