# encoding: utf-8

class ShopButtonImageUploader < BaseImageUploader

  def filename
     "shop_button_#{secure_token}.#{File.extname(original_filename).downcase}" if original_filename.present?
  end

  version :thumb do
    process :resize_to_fill => [180,180]
  end

  version :mini do
    process :resize_to_fill => [60, 60]
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end

