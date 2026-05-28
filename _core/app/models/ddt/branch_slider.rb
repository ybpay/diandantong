# encoding: utf-8
module Ddt
  class BranchSlider < Ddt::Base
    include Ddt::ListScope

    acts_as_list scope: :shop

    ### relationships
    belongs_to :shop, class_name: "Ddt::Shop", touch: true

    ### validations
    validates :url, presence: true, uri: true, length: { maximum: 255 }
    validates :img, presence: true, file_size: {
        maximum: 0.5.megabytes.to_i
      }, if: :img_changed?

    filter_urls_for :url

    include Ddt::Attachable
    attachable_one :img, variants: { medium: [720, 270], thumb: [180, 67] }
  end
end
