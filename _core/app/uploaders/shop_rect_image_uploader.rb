# encoding: utf-8

class ShopRectImageUploader < BaseImageUploader

  def default_url
    ActionController::Base.helpers.asset_url('ddt/images/shop_rect.png')
  end

  version :medium do
    process :resize_to_fill => WECHAT_COVER
  end

  version :thumb do
    process :resize_to_fill => [180,100]
  end

end
