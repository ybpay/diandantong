# encoding: utf-8

class ShopVipLogoUploader < BaseImageUploader

  # def default_url
  #   ActionController::Base.helpers.asset_url('ddt/images/shop_vip_logo.png')
  # end


  version :thumb do
    process :resize_to_fit => [360,200]
  end

end
