#encoding: utf-8
module Ddt
  class HomeHotLink < Base
    include Ddt::BelongsToShop
    include Ddt::ListScope


    belongs_to :custom_weixin_info , class_name: 'Ddt::CustomWeixinInfo', touch: true
    acts_as_list scope: [:custom_weixin_info]
    include Ddt::Attachable
    attachable_one :image, variants: { medium: [400, 400], thumb: [140, 140] }

    validates_presence_of :label, :link
    validates :image, file_size: { maximum: 0.5.megabytes.to_i } , if: :image?

    filter_urls_for :link

    set_from :custom_weixin_info
    default_scope ->{ list_order }
  end
end
