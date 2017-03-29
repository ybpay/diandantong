class CreateBranchExts < ActiveRecord::Migration
  def change
    create_table :ddt_branch_exts do |t|
      t.references :branch, index: true
      t.string :wifi_code
      
      t.timestamps
    end
  end
end