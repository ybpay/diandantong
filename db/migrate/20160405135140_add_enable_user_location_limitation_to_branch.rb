class AddEnableUserLocationLimitationToBranch < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :enable_user_location_limitation, :boolean, default: false
  end
end
