class ChangeIsAutoConfirmDefault < ActiveRecord::Migration
  def change
    change_column_default :ddt_branches, :is_auto_confirm, false
  end
end
