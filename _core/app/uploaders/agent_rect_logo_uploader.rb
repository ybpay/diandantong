# encoding: utf-8

class AgentRectLogoUploader < BaseImageUploader

  def default_url
    ActionController::Base.helpers.asset_url('ddt/images/shop_rect.png')
  end

  version :medium do
    process :resize_to_fill => [800, 300]
  end

  version :thumb do
    process :resize_to_fill => [267,100]
  end

end
