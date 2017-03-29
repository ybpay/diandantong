#encoding: utf-8
module Ddt
  class OnePage < Ddt::Base
    include ListScope
    replicated_model

    acts_as_list
    acts_as_type :alignment, %W[top bottom left right], %W[靠上 靠底 靠左 靠右]
    belongs_to :shop, class_name: "Ddt::Shop", touch: true

    require 'carrierwave/orm/activerecord'
    mount_uploader :image, OnePageImageUploader
    validates :image, presence: true, file_size: {
        maximum: 0.5.megabytes.to_i
      }

  end
end
