# encoding: utf-8

class AgentLogoUploader < BaseImageUploader

  def default_url
    ActionController::Base.helpers.asset_url('ddt/images/shop_rect.png')
  end

  version :medium do
    process :resize_to_fill => [400,400]
  end

  version :thumb do
    process :resize_to_fill => [140,140]
  end

end
