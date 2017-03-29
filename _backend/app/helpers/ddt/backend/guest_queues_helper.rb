# encoding:utf-8
module Ddt
  module Backend
    module GuestQueuesHelper
      def guest_queue_state_label(guest_queue)
        label_class = case guest_queue.workflow_state.to_sym
                      when :queueing
                        'label-success'
                      when :accepted
                        'label-info'
                      when :canceled, :past
                        'label-default'
                      end
        content_tag(:span, guest_queue.workflow_state_name, class: "label #{label_class}")
      end

      def guest_queue_notify_label(guest_queue)
        label_class = guest_queue.is_notified ? 'label-success' : 'label-default'
        content_tag(:span, guest_queue.is_notified ? '已通知' : '未通知', class: "label #{label_class}")
      end

      def guest_queue_action(guest_queue, action, options={})
        options[:method] ||= :put
        options[:remote] ||= false
        action_name = { accept: '接受', pass: '过号', cancel: '取消' }[action]
        link_to(action_name, [action, :backend, @current_shop, guest_queue.branch, guest_queue.queue_setting, guest_queue], options)
      end
    end
  end
end