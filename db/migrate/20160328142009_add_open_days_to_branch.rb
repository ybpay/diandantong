class AddOpenDaysToBranch < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :open_on_monday, :boolean, default: true
    add_column :ddt_branches, :open_on_tuesday, :boolean, default: true
    add_column :ddt_branches, :open_on_wednesday, :boolean, default: true
    add_column :ddt_branches, :open_on_thursday, :boolean, default: true
    add_column :ddt_branches, :open_on_friday, :boolean, default: true
    add_column :ddt_branches, :open_on_saturday, :boolean, default: true
    add_column :ddt_branches, :open_on_sunday, :boolean, default: true

    Ddt::Branch.where(is_open: false).update_all("open_on_sunday = 0, open_on_tuesday=0, open_on_wednesday=0, open_on_thursday=0, open_on_friday=0, open_on_saturday=0, open_on_sunday=0")
    
  end
end
