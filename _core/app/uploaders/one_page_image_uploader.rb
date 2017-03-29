#encoding: utf-8
class OnePageImageUploader < BaseImageUploader

  def default_url
    '/assets/one-page-fashion.jpg'
  end

  version :medium do
    process :resize_to_fit => [640, 1010]
  end

  version :thumb do 
    process :resize_to_fit => [64, 101]
  end
end

