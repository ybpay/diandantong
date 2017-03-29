class FixCreditsSetting < ActiveRecord::Migration
  def up
    Ddt::Shop.includes(:credits_setting).where("ddt_credits_settings.id IS NULL").references(:ddt_credits_settings).each do |shop|
      shop.create_credits_setting!
    end
  end

  def down
  end
end
