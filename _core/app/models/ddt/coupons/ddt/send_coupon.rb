
module Ddt
  class SendCoupon
    attr_accessor :shop_id, :coupon_version_id, :count, :to_user_ids, :caller_type, :caller_id

    def initialize(attrs={})
      attrs = attrs.symbolize_keys
      @shop_id = attrs[:shop_id]
      @coupon_version_id = attrs[:coupon_version_id]
      @count = attrs[:count] || 1
      @to_user_ids = attrs[:to_user_ids]
      @caller_type = attrs[:caller_type]
      @caller_id = attrs[:caller_id]
    end

    def perform
      result = {
        total_count: 0,
        success_count: 0,
        fail_total_count: 0,
        fail_reason: {
          not_user: 0,
          not_subscribed: 0,
          not_interactive: 0
        }
      }
      shop = Ddt::Shop.find(shop_id)
      coupon_version = shop.coupon_versions.find(coupon_version_id)
      base_users = shop.base_users.find(to_user_ids)
      Ddt::Coupon.transaction do
        base_users.each do |base_user|
          count.to_i.times do
            Ddt::BaseCoupon.notify = false
            coupon_version.send_coupon_to_user(base_user, :promotion)
          end
          fail = false
          if !fail && base_user.type != 'Ddt::User'
            result[:fail_reason][:not_user] += 1
            fail = true
          end
          wechat_user = base_user.try(:primary_wechat_user)
          if !fail && (wechat_user.blank? || !wechat_user.subscribed?)
            result[:fail_reason][:not_subscribed] += 1
            fail = true
          end
          if !fail && Ddt::MessageReception.where(from_user_name: wechat_user.user_open_id, to_user_name: shop.primary_wechat_account.gonghao_open_id, created_at: 48.hours.ago..Time.now).blank?
            result[:fail_reason][:not_interactive] += 1
            fail = true
          end
          unless fail
            coupons_url = URI.join(Rails.application.routes.url_helpers.ddt_url, "weixin/shops/#{shop.id}/my?_ng_path=/user/coupons").to_s
            article_options = {
              title: "恭喜您获得了#{count}张优惠券(#{coupon_version.name})",
              description: "",
              url: coupons_url
            }
            base_user.shop.notify_to(base_user, article_options)
          end
        end
      end
      result[:total_count] = base_users.count
      result[:fail_total_count] = result[:fail_reason].values.inject(:+)
      result[:success_count] = result[:total_count] - result[:fail_total_count]
      result
      result = to_label(result)
      if caller_id.present?
        caller_type.constantize.find(caller_id).append_log(result)
      else
        return result
      end
    end

    def to_label(result)
      [
        ("优惠券发放成功, 总计#{result[:total_count]}人, 微信消息发送成功#{result[:success_count]}人"),
        ("失败#{result[:fail_total_count]}人, 其中 " if result[:fail_total_count] > 0),
        ("#{result[:fail_reason][:not_user]}人不是微信用户" if result[:fail_reason][:not_user] > 0),
        ("#{result[:fail_reason][:not_subscribed]}人未关注" if result[:fail_reason][:not_subscribed]),
        ("#{result[:fail_reason][:not_interactive]}人48小时内未互动" if result[:fail_reason][:not_interactive] > 0)
      ].compact.join(", ")
    end

  end
end
