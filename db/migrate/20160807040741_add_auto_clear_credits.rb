class AddAutoClearCredits < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_credits_settings, :auto_clear_credits
      add_column :ddt_credits_settings, :auto_clear_credits, :boolean, default: false
    end
  end
end
