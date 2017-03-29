# encoding: utf-8

class ArticleImageUploader < BaseImageUploader


  def default_url
    ActionController::Base.helpers.asset_url('ddt/images/missing.png')
  end

  def filename
     "article_#{secure_token}.#{File.extname(original_filename).downcase}" if original_filename.present?
  end

  version :thumb do
    process :resize_to_fill => [400,400]
  end

  version :medium do
    process :resize_to_fill => WECHAT_COVER
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end
