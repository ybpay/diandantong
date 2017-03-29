module Ddt
  class Notification
    module View
      class Base
        attr_accessor :event, :target

        delegate :order, :branch, :shop, :guest_queue, :base_coupon,
                :order_change_log, :table, :variant, :user, :wallet_log,
                 :guest, :inviter, :system_message, :printer, to: :event, allow_nil: true

        def initialize(event, target)
          @event = event
          @target = target
        end

        def render
          send("render_#{event_type}")
        end

        protected

        # "Ddt::Notification::Event::Order::Placed" => :order_placed
        # "Ddt::Notification::Event::OrderChange::AppendItemable" => :order_change_append_itemable
        def event_type
          @event.class.name.split("::").last(2).join('_').underscore.to_sym
        end

        private

        # "Ddt::User" => :user
        # "Ddt::Printer::Feiyin" => :printer
        def target_type
          @target.class.model_name.to_s.demodulize.underscore.to_sym
        end
      end
    end
  end
end
