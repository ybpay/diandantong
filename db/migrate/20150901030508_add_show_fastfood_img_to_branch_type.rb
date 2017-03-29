class AddShowFastfoodImgToBranchType < ActiveRecord::Migration
  def change
      add_column :ddt_branch_types, :show_fastfood_img, :boolean, default: false
      add_column :ddt_branch_types, :fastfood_img_text, :string
      add_column :ddt_branch_types, :fastfood_img, :string
  end
end
