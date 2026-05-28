#encoding: utf-8
module Ddt
  class OnePage < Ddt::Base
    include ListScope

    acts_as_list
    acts_as_type :alignment, %W[top bottom left right], %W[靠上 靠底 靠左 靠右]
    belongs_to :shop, class_name: "Ddt::Shop", touch: true

    include Ddt::Attachable
    attachable_one :image, variants: { medium: [640, 1010], thumb: [64, 101] }
    validates :image, presence: true, file_size: {
        maximum: 0.5.megabytes.to_i
      }

  end
end
