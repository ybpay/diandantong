#encoding: utf-8
module Ddt
  class CustomWeixinInfo < Base

    belongs_to :shop, class_name: "Ddt::Shop", touch: true
    acts_as_type :layout_type, %W[classic classic2 fashion fashion2], %W[经典版01 经典版02 时尚版01 时尚版02]
    acts_as_type :branch_index_layout, %W[list block], %W[列表型 方块型]
    validates_presence_of :layout_type, :branch_index_layout

    has_many :home_hot_links, class_name: 'Ddt::HomeHotLink'
    has_many :home_usable_links, class_name: 'Ddt::HomeUsableLink'
    include Ddt::CarrierWaveBridge
    mount_uploader :background_image, OnePageImageUploader
    validates :background_image, file_size: {
        maximum: 0.5.megabytes.to_i
      }
  end
end