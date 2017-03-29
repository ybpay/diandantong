class AddMaterialIdToQrCodeScene < ActiveRecord::Migration
  def change
    add_column :ddt_base_qr_code_scenes, :scene_type, :string
    add_column :ddt_base_qr_code_scenes, :material_id, :integer
    add_column :ddt_base_qr_code_scenes, :branch_id, :integer
  end
end
