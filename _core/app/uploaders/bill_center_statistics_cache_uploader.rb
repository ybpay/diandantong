class BillCenterStatisticsCacheUploader < CarrierWave::Uploader::Base

  def content_disposition
    "attachment;filename=#{file.original_filename}"
  end

  def store_dir
    'uploads/bill-center-statistics-cache'
  end

  storage :aliyun
end
