# encoding: utf-8

class CouponImageUploader < BaseImageUploader
  version :medium do
    process :resize_to_fill => [720,360]
  end

  version :thumb do
    process :resize_to_fill => [240,120]
  end

  version :thumb_square do
    process :resize_to_fill => [120,120]
  end

end
