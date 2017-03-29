class AddIsShowOrderQrcodeToPrintSetting < ActiveRecord::Migration
  def change
    add_column :ddt_print_settings, :is_show_order_qrcode, :boolean, :default => false
  end
end
