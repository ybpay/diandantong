# encoding: utf-8

class BranchRectImageUploader < BaseImageUploader

  def default_url
    ActionController::Base.helpers.asset_url('ddt/images/branch_rect.png')
  end

  version :medium do
    process :resize_to_fill => WECHAT_COVER
  end

  version :thumb do
    process :resize_to_fill => [180,100]
  end

end
