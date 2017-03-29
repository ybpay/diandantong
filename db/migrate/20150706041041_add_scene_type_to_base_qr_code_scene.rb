class AddSceneTypeToBaseQrCodeScene < ActiveRecord::Migration
  def change
    add_column :ddt_base_qr_code_scenes, :wechat_scene_type, :string
    add_column :ddt_base_qr_code_scenes, :snap_scene_type, :string
    rename_column :ddt_base_qr_code_scenes, :scene_type, :limit_scene_type
    Ddt::WechatQrCodeScene.all.update_all(wechat_scene_type: 'limit')
  end
end
