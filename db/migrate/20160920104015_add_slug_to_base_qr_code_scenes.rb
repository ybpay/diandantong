class AddSlugToBaseQrCodeScenes < ActiveRecord::Migration
  def change
    add_column :ddt_base_qr_code_scenes, :slug, :string
    Ddt::BaseQrCodeScene.where('slug IS NULL').update_all('slug = `id`')
  end
end
