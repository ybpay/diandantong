class AddIsEnableToBaseQrCodeScene < ActiveRecord::Migration
  def change
    add_column :ddt_base_qr_code_scenes, :is_enable, :boolean, default: true
  end
end
