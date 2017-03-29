module Ddt
  class NotificationReceiveSetting < Ddt::Base
    replicated_model

    belongs_to :shop
    belongs_to :account
    set_shop_from :account
    serialize :settings, Hash

    def self.all_settings_hash
      {
        order_placed:                 [ :backend, :app, :system_weixin, :email, :sms ],
        order_confirmed:              [ :backend, :app, :system_weixin, :email ],
        order_paid:                   [ :backend, :app, :system_weixin, :email ],
        order_canceled:               [ :backend, :app, :system_weixin, :email ],
        order_call_waiter:            [ :backend, :app, :system_weixin ],
        order_hasten:                 [ :backend, :app, :system_weixin ],
        order_request_pay:            [ :backend, :app ],
        order_change_append_itemable: [ :backend, :app, :email ],
        order_change_delete_itemable: [ :backend, :app, :email ],
        product_stock_empty:          [ :backend, :app ],
        queue_enqueueing:             [ :app ],
        queue_accepted:               [ :app ],
        queue_past:                   [ :app ],
        queue_cancel:                 [ :app ],
        queue_binded:                 [ :app ],
        shipment_assigned:            [ :app, :system_weixin ],
        shipment_unassigned:          [ :app, :system_weixin ],
        shipment_started:             [ :app, :system_weixin ],
        shipment_shipped:             [ :app, :system_weixin ],
        table_opened:                 [ :backend, :app ],
        table_cleared:                [ :backend, :app ],
        table_changed:                [ :backend, :app, :system_weixin ],
        table_merged:                 [ :backend, :app, :system_weixin ],
        table_move_itemable:          [ :backend, :app, :system_weixin ]
      }
    end

    def self.all_settings
      all_settings_hash.map{|event, actions| actions.map{|action| "#{event}__#{action}".to_sym}}.flatten
    end

    def need_notify?(event_name, action_name)
      self.send("#{event_name}__#{action_name}?")
    end

    all_settings.each do |key|
      define_method key do
        default_value = (key.to_s.start_with?('order_placed') || key.to_s.start_with?('order_paid') || key.to_s.start_with?('order_canceled')) && 
          (key.to_s.end_with?('app') || key.to_s.end_with?('system_weixin'))
        self.settings.fetch(key, default_value)
      end
      alias_method "#{key}?", key
      define_method "#{key}=" do |value|
        self.settings[key] = ['true', true, '1', 1].include?(value)
      end
    end

    def active_settings
      self.class.all_settings.map do |key|
        key if self.send(key)
      end.compact
    end

    def active_settings_text
      NotificationReceiveSetting.all_settings_hash.select{|event, actions|
        actions.any?{|action| self.send("#{event}__#{action}")}
      }.map{|event, actions|
        event_name = NotificationReceiveSetting.event_name(event)
        action_names = actions.select{|action| self.send("#{event}__#{action}")}.map{|action| NotificationReceiveSetting.action_name(action)}
        "#{event_name}[#{action_names.join(",")}]"
      }
    end

    def self.event_name(event)
      I18n.t("activerecord.attributes.ddt/notification_receive_setting.#{event}")
    end

    def self.action_name(action)
      I18n.t("activerecord.attributes.ddt/notification_receive_setting.#{action}")
    end

    def self.setting_name(setting)
      if setting.to_s =~ /^(.+?)__(.+?)$/
        "#{event_name($1)}(#{action_name($2)})"
      end
    end
  end
end
