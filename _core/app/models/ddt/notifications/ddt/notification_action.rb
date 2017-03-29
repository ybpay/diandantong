module Ddt
  class NotificationAction
    include NotificationConcern
    attr_accessor :notification_event
    belongs_to :notification_target, polymorphic: true
    delegate :order_id, :order, :shop, :shop_id, :branch, :branch_id, to: :notification_event, allow_nil: true
    alias_method :event, :notification_event
    alias_method :target, :notification_target
    delegate :can_perform?, to: :event

    def type_sym
      self.class.name.demodulize.underscore.to_sym
    end

    def perform
      raise "perform should be implemented in (#{self.class.name}) sub-class of NotificationAction"
    end

  end
end
