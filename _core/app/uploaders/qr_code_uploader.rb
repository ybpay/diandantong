# encoding: utf-8

class QrCodeUploader < BaseImageUploader

  version :medium do
    process :resize_to_fill => [400,400]
  end

  version :thumb do
    process :resize_to_fill => [100,100]
  end

end
