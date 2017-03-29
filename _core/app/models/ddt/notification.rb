module Ddt
  class Notification
    include NotificationConcern
    attr_accessor :notification_event
    delegate :shop, to: :notification_event
    belongs_to :notification_target, polymorphic: true
    delegate :order, to: :notification_event, allow_nil: true

    alias_method :event, :notification_event
    alias_method :target, :notification_target

    def init_actions
      action_types = event.action_types_of_target(target_type, target) & self.available_action_types
      if (action_types)
        action_types.map do |action_type|
          Ddt::Notification::Action.const_get(action_type.to_s.camelize).new(
            notification_event: notification_event,
            notification_target: notification_target
          )
        end
      else
        []
      end
    end

    # "Ddt::Notification::Event::Order::Placed" => :order_placed
    # "Ddt::Notification::Event::OrderChange::AppendItemable" => :order_change_append_itemable
    def event_type
      event.event_type
      # event.class.name.split("::").last(2).join('_').underscore.to_sym
    end

    # "Ddt::User" => :user
    # "Ddt::Printer::Feiyin" => :printer
    def target_type
      target.class.model_name.to_s.demodulize.underscore.to_sym
    end

    def available_action_types
      action_types = []
      case target_type
      when :account
        action_types << :backend
        action_types << :webpos
        action_types << :sms           if can_sms?
        action_types << :system_weixin if can_system_weixin?
        action_types << :email         if target.notification_email.present?
        action_types << :app
      when :user
        action_types << :weixin        if can_weixin?
        action_types << :sms           if can_sms?
      when :phone_user
        action_types = []
      when :web_user
        action_types << :email         if target.email.present?
      when :printer
        action_types << :printer
      when :branch
        action_types << :cloud_server
      end
      action_types
    end

    private
    def can_weixin?
      target_type == :user &&
      shop.primary_wechat_account.try(:account_service?) &&
      target.primary_wechat_user.try(:subscribed?)
    end

    def can_system_weixin?
      target_type == :account &&
      target.user.present?
    end

    def can_sms?
      [:account, :user].include?(target_type) && shop.try(:can_use_order_sms?) && shop.short_message_setting.remaining_count > 0
    end
  end
end
