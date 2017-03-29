class AddAutoUploadAfterShift < ActiveRecord::Migration
  def change
    add_column :ddt_sale_data_uploader_settings, :auto_upload_after_shift, :boolean, default: false
  end
end
