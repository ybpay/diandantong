# encoding: utf-8

class BranchTypeImageUploader < BaseImageUploader

  def default_url
    ActionController::Base.helpers.asset_url('ddt/images/branch_type.png')
  end

  version :thumb do
    process :resize_to_fill => [100,100]
  end

end
