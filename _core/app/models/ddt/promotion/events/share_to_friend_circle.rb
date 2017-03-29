module Ddt
  class Promotion
    module Events
      class ShareToFriendCircle < ::Ddt::PromotionEvent
        def action_performed
          wechat_share_record = self.wechat_share_record
          wechat_share_record.update(is_got_promotion: true)
        end
      end
    end
  end
end
