# frozen_string_literal: true

module Ddt
  module ShopService
    class << self
      def find!(slug)
        Shop.friendly.find(slug)
      end

      def active_branches(shop)
        shop.branches.open_on_today
      end

      def active_branches_by_distance(shop, user)
        shop.active_branches.map { |b| [b, b.distance_of(user)] }
            .sort { |a, b| sort_branches_by_distance(a, b) }
            .map(&:first)
      end

      def upgrade_shop(shop, new_type:, max_branches:, expired_at:, skip_check: false)
        unless skip_check || Ddt::FeatureModuleGroup.can_upgrade_to?(shop, max_branches, new_type)
          raise ArgumentError, "升级策略不允许"
        end

        ApplicationRecord.transaction do
          fmg = Ddt::FeatureModuleGroup.send(new_type.to_sym)
          fmg[:modules].each do |fm|
            fmc = shop.feature_modules_configs.where(feature_module: fm).first_or_initialize
            fmc.expired_at = expired_at if fmc.expired_at.nil? || fmc.expired_at < expired_at
            fmc.save!
          end
          shop.update!(
            shop_type: new_type,
            max_branches_limit: max_branches,
            expiration_time: expired_at
          )
        end
      end

      def expired?(shop)
        shop.expiration_time < Time.current
      end

      def in_recharge_time_range?(shop)
        (shop.expiration_time - 1.month) < Time.current
      end

      def active_payment_method(shop, pay_type)
        case pay_type.to_sym
        when :alipay    then shop.current_alipay_method
        when :wechatpay then shop.current_wechatpay_method
        when :baidu      then shop.current_baidupay_method
        else nil
        end
      end

      def send_birthday_promotions(shop, advance_days: 0)
        vips = shop.birthday_vips(advance_days: advance_days)
        return if vips.blank?

        year = Time.current.year.to_s
        events = vips.uniq.map do |vip|
          Ddt::Promotion::Events::VipBirthday.new(user: vip.user, uuid: SecureRandom.uuid)
        end

        Ddt::Promotion::Events::VipBirthday.import(events)
        Ddt::PromotionEvent.where(uuid: events.map(&:uuid)).each do |event|
          event.send(:handle_promotion)
        end
      end

      def send_birthday_sms(shop)
        sms_body = shop.short_message_setting.birthday_message
        return unless sms_body.present?

        shop.birthday_vips(advance_days: 0).uniq.each do |vip|
          sms = Ddt::ShortMessage.wrap_birthday_message_to_send(shop, vip.phone, sms_body)
          sms.save
        end
      end

      def shop_json(shop)
        { id: shop.id, name: "#{shop.slug}-#{shop.name}" }
      end

      def branches_select_json(shop, range_branches:, all_branch_ids:)
        json = []
        json << { id: all_branch_ids, name: '所有门店' } if all_branch_ids.present?
        shop.branch_groups.each do |group|
          json << { id: group.branch_ids.join(','), name: group.name }
        end
        json.concat(range_branches.map(&:select_json))
      end

      private

      def sort_branches_by_distance(a, b)
        if a[1].present? && b[1].present?
          (a[1] <= 500 && b[1] <= 500) ? a[0].position <=> b[0].position : a[1] <=> b[1]
        elsif a[1].blank? && b[1].blank?
          a[0].position <=> b[0].position
        else
          a[1].blank? ? 1 : -1
        end
      end
    end
  end
end
