class RemoveColumnToPrintSetting < ActiveRecord::Migration
  def change
    [
      :page_header,
      :page_footer,
      :is_show_joke,
      :is_show_queue_qrcode,
      :preferences,
      :qrcode_image_type,
      :consume_bill_header,
      :consume_bill_footer,
      :product_bill_header,
      :product_bill_footer,
    ].each do |column|
      remove_column :ddt_print_settings, column if column_exists? :ddt_print_settings, column
    end
  end
end
