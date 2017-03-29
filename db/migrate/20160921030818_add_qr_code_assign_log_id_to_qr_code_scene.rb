class AddQrCodeAssignLogIdToQrCodeScene < ActiveRecord::Migration
  def change
    add_column :ddt_base_qr_code_scenes, :qr_code_assign_log_id, :integer
    add_index :ddt_base_qr_code_scenes, :qr_code_assign_log_id
  end
end
