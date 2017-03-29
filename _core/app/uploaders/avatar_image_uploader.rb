# encoding: utf-8

class AvatarImageUploader < BaseImageUploader


  version :medium do
    process :resize_to_fill => [400,400]
  end

  version :thumb do
    process :resize_to_fill => [140,140]
  end

end
