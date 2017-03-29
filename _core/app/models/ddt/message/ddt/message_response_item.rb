module Ddt
  class MessageResponseItem < Ddt::DdtEx
    include Ddt::BelongsToShop
    belongs_to :message_response, counter_cache: :article_count,class_name: 'Ddt::MessageResponse'

    validates_presence_of :message_response
    # pic_url url title description

    before_validation :set_shop_from_message_response

    private
    def set_shop_from_message_response
      if self.message_response.present?
        self.shop_id = self.message_response.shop_id if self.shop_id.blank?
      end
    end
  end
end