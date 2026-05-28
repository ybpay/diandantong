module Ddt
  class HomeUsableLink < Base
    include Ddt::BelongsToShop
    include Ddt::ListScope

    belongs_to :custom_weixin_info , class_name: 'Ddt::CustomWeixinInfo', touch: true
    acts_as_list scope: [:custom_weixin_info]
    include Ddt::Attachable
    attachable_one :image, variants: { medium: [720, 400], thumb: [164, 80] }

    validates_presence_of :title, :keywords
    validates :link, uri: true, presence: true, length: { maximum: 255 }
    validates :image, file_size: { maximum: 0.5.megabytes.to_i } , if: :image?

    filter_urls_for :link

    set_from :custom_weixin_info
    default_scope ->{ list_order }
  end
end
