class HomeUsableImageUploader < BaseImageUploader

  version :medium do
    process :resize_to_fill => [720,400]
  end

  version :thumb do
    process :resize_to_fill => [164,80]
  end

end
