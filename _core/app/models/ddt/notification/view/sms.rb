module Ddt
  class Notification
    module View
      class Sms < Ddt::Notification::View::Base
        def render_order_placed
          [:order, order.order_detail_in_sms]
        end

        def render_captcha

        end

        def render_user_card_wallet_change
          content = [:card_wallet_change]
          reason_str = (wallet_log.reason == "for_recharge") ? "充值" : "消费"
          detail_array = []
          detail_array << "尊敬的: #{user.vip_info.name} 会员\n"
          detail_array << "您于 #{wallet_log.updated_at} #{reason_str} #{wallet_log.amount}\n"
          detail_array << "账户余额为: #{wallet_log.wallet.amount}"
          content << detail_array
          content
        end

      end
    end
  end
end