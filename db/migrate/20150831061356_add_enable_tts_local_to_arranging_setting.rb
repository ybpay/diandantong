class AddEnableTtsLocalToArrangingSetting < ActiveRecord::Migration
  def change
    add_column :ddt_arranging_settings, :enable_tts_local, :boolean, default: false
  end
end
