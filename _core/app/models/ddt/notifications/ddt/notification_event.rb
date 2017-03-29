module Ddt
  class NotificationEvent
    include NotificationConcern
    belongs_to :shop
    belongs_to :operator, class_name: "Ddt::Account"
    delegate :name, to: :operator, prefix: true, allow_nil: true

    attribute :terminal_id, :created_at, :uuid, :sync

    def self.create_and_send_notification(params = {})
      notification_event = self.new(params.merge(created_at: Time.now))
      notification_event.uuid = SecureRandom.uuid
      if notification_event.sync
        self.send_notification(notification_event.attributes)
      else
        self.delay_for(1.second, queue: :critical, expires_in: 1.days).send_notification(notification_event.attributes)
      end
      notification_event
    end

    def can_perform?
      true
    end

    def notification_targets
      raise "notification_targets should be implemented in (#{self.class.name}) sub-class of NotificationEvent"
    end

    def action_types_of_target(target_type, target)
      raise "action_types_of_target should be implemented in (#{self.class.name}) sub-class of NotificationEvent"
    end

    def self.send_notification(attributes)
      event = self.init(attributes)
      notifications = event.notification_targets.map do |target|
        Ddt::Notification.new(notification_event: event, notification_target: target)
      end
      actions = notifications.map{|it| it.init_actions}.flatten.compact
      actions.each do |action|
        action_type_sym = action.type.demodulize.underscore.to_sym
        action_queue_name = Ddt::NotificationActionConfig.send(action_type_sym)
        worker = Ddt::Notification::ActionWorker.const_get(action_queue_name.to_s.camelize)
        if event.sync
          worker.new.perform(attributes, action.attributes)
        else
          worker.perform_in(1.second, attributes, action.attributes)
        end
      end
    end

    def event_type
      self.class.name.split("::").last(2).join('_').underscore.to_sym
    end

    def created_at_time
      created_at.is_a?(String) ? Time.parse(created_at) : created_at
    end

    def created_at_str
      created_at_time.strftime("%F %T")
    end

  end
end
