# encoding: utf-8

class ComboImageUploader < BaseImageUploader

  def default_url
    ActionController::Base.helpers.asset_url('ddt/images/product0.png')
  end

  # version :mini do
  #   process :resize_to_fill => [48, 48]
  # end

  # version :rect_mini do
  #   process :resize_to_fill => [48, 26]
  # end

  version :small do
    process :resize_to_fill => [100, 100]
  end

  # version :rect_small do
  #   process :resize_to_fill => [100, 56]
  # end

  # version :normal do
  #   process :resize_to_fill => [240, 240]
  # end

  version :rect_normal do
    process :resize_to_fill => [240, 133]
  end

  # version :large do
  #   process :resize_to_fill => [720, 720]
  # end

  version :rect_large do
    process :resize_to_fill => [720, 400]
  end

end
