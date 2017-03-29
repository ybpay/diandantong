class RemoveAutoClear < ActiveRecord::Migration
  def change
    remove_column :ddt_credits_settings, :auto_clear, :boolean, default: false
    remove_column :ddt_credits_settings, :auto_clear_date, :datetime
  end
end
