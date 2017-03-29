class ShopLastImportVipInfoErrorUploader < CarrierWave::Uploader::Base

  class File < StringIO
    attr_accessor :original_filename
    def initialize(content)
      super(content)
      self.original_filename = 'import_vip_info_errors.xls'
    end

  end

  def store_dir
    "uploads/import_vip_info_error/#{model.id}"
  end

  storage :aliyun
end
