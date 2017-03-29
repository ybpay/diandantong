class AddIndexToBaseQrCodeSceneSlug < ActiveRecord::Migration
  def change
    add_index :ddt_base_qr_code_scenes, :slug, unique: true
  end
end
