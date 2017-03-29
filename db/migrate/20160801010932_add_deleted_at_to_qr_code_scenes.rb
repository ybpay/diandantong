class AddDeletedAtToQrCodeScenes < ActiveRecord::Migration
  def change
    add_column :ddt_base_qr_code_scenes, :deleted_at, :datetime
  end
end
