# encoding: utf-8
require 'cgi'
module Ddt
  class Promotion
    module Rules
      module Event
        class ShareToFriendCircle < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          preference :page_identifier, :string, default: ""
          preference :view_user_num, :integer, default: 1

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::ShareToFriendCircle)
          end

          def eligible?(promotable)
            wechat_share_record = promotable.wechat_share_record
            same_page?(page_identifier, wechat_share_record.page_identifier) &&
              !wechat_share_record.is_got_promotion? &&
              wechat_share_record.viewed_users_count == preferred_view_user_num
          end

          def same_page?(a, b)
            CGI.unescape(a||'') == CGI.unescape(b||'')
          end

          def page_identifier
            return "" if preferred_page_identifier.blank?
            Ddt::UrlUtil.get_query(preferred_page_identifier, '_ng_path')
          end

        end
      end
    end
  end
end
