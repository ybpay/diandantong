class AddIsAutoConfirmToBranches < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_branches, :is_auto_confirm
      add_column :ddt_branches, :is_auto_confirm, :boolean, default: true
    end
  end
end
