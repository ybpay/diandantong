class AddIsShowQueueQrcodeToPrintSettings < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_print_settings, :is_show_queue_qrcode
      add_column :ddt_print_settings, :is_show_queue_qrcode, :boolean, default: false
    end
  end
end
