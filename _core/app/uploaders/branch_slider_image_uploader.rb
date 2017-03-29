# encoding: utf-8
class BranchSliderImageUploader < BaseImageUploader

  def default_url
    # ActionController::Base.helpers.asset_url('ddt/images/branch_slider.png')

  end

  # Include RMagick or MiniMagick support:
  #include CarrierWave::RMagick
  #include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  #storage :azure
  # storage :fog

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
     "branch_slider_#{secure_token}.#{File.extname(original_filename).downcase}" if original_filename.present?
  end

  version :medium do
    process :resize_to_fill => [720,270]
  end

  version :thumb do
    process :resize_to_fill => [180,67]
  end


  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end
