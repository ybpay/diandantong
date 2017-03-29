class AddAutoClearToCreditsSetting < ActiveRecord::Migration
  def change
    add_column :ddt_credits_settings, :auto_clear, :boolean, default: false
    add_column :ddt_credits_settings, :auto_clear_date, :datetime
  end
end
