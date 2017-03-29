# encoding: utf-8

class BranchImageUploader < BaseImageUploader

  def default_url
    ActionController::Base.helpers.asset_url('ddt/images/branch.png')
  end

  version :medium do
    process :resize_to_fill => [400,400]
  end

  version :thumb do
    process :resize_to_fill => [140,140]
  end

end
