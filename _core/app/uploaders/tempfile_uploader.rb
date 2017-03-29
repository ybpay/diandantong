class TempfileUploader < CarrierWave::Uploader::Base

  after :store, :delete_old_tmp_file

  # remember the tmp file
  def cache!(new_file)
    super
    @old_tmp_file = new_file
  end

  def delete_old_tmp_file(dummy)
    @old_tmp_file.try :delete
  end

  def store_dir
    "uploads/tempfile/#{model.id}"
  end

  # def extension_white_list
  #   %w(xsl doc docx wps)
  # end

  # Choose what kind of storage to use for this uploader:
  #storage :azure
  storage :aliyun
  # storage :fog
end
