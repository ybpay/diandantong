# encoding: utf-8

class BaseImageUploader < CarrierWave::Uploader::Base

  WECHAT_COVER = [900, 500]

  # Choose what kind of storage to use for this uploader:
  #storage :azure
  # storage :aliyun
  # storage :fog
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  after :store, :delete_old_tmp_file

  # remember the tmp file
  def cache!(new_file)
    super
    @old_tmp_file = new_file
  end

  def delete_old_tmp_file(dummy=nil)
    @old_tmp_file.try :delete
  end

  def store_dir
    if Rails.env.test?
      "test/ddb_uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    else
      "ddb_uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
