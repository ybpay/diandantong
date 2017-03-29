# encoding: utf-8
module Ddt
  class BranchSlider < Ddt::Base
    include Ddt::ListScope
    replicated_model

    acts_as_list scope: :shop

    ### relationships
    belongs_to :shop, class_name: "Ddt::Shop", touch: true

    ### validations
    validates :url, presence: true, uri: true, length: { maximum: 255 }
    validates :img, presence: true, file_size: {
        maximum: 0.5.megabytes.to_i
      }, if: :img_changed?

    filter_urls_for :url

    require 'carrierwave/orm/activerecord'
    mount_uploader :img, BranchSliderImageUploader
  end
end
