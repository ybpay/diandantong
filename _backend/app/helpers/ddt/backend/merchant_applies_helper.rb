# encoding: utf-8
module Ddt
  module Backend
    module MerchantAppliesHelper
      def merchant_apply_actions(merchant_apply)
        if merchant_apply.current_state == :applying
          actions = [:confirm, :reject]
          actions.map do |action|
            url = url_for([action, :backend, @current_shop, merchant_apply])
            case action
            when :confirm
              remote_link_tag(url, "btn btn-xs btn-primary", "fa fa-check", "确认")
            when :reject
              remote_link_tag(url, "btn btn-xs", "fa fa-remove", "拒绝", 'data-confirm' => "确定拒绝？")
            end
          end.join(' ').html_safe
        end
      end

      def merchant_apply_state_label(merchant_apply)
        classes = {
          applying: 'label-primary',
          confirmed: 'label-success',
          rejected: 'label-warning',
          canceled: 'label-default'
        }
        label_class = classes[merchant_apply.current_state.to_sym]
        content_tag(:span, merchant_apply.workflow_state_name, class: "label #{label_class}")
      end

    end
  end
end
