class StatisticsCacheUploader < CarrierWave::Uploader::Base
  def content_disposition
    "attachment;filename=#{file.original_filename}"
  end

  def store_dir
    "uploads/statistics-cache/#{model.id}"
  end

  storage :aliyun
end
