class PromotionImageUploader < BaseImageUploader

  version :medium do
    process :resize_to_fill => [720,270]
  end

  version :thumb do
    process :resize_to_fill => [180,67]
  end

end
