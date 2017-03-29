class AddTrackFromToRegisterForm < ActiveRecord::Migration
  def change
    add_column :ddt_register_forms, :track_from, :string
  end
end
