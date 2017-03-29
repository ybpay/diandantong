class AddQrcodeImageTypeToPrintSetting < ActiveRecord::Migration
  def change
    add_column :ddt_print_settings, :qrcode_image_type, :string, default: :pcn_qrcode
    Ddt::PrintSetting.where(is_show_qrcode: true).update_all(qrcode_image_type: :pcn_qrcode)
    Ddt::PrintSetting.where(is_show_qrcode: false, is_show_order_qrcode: true).update_all(qrcode_image_type: :order_qrcode)
    remove_column :ddt_print_settings, :is_show_qrcode, :boolean
    remove_column :ddt_print_settings, :is_show_order_qrcode, :boolean
  end
end
