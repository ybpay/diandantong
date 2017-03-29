# encoding:utf-8
module Ddt
  module Backend
    module ExchangeCodesHelper
      def exchange_code_state_label(exchange_code)
        label_class = case exchange_code.state.to_sym
                      when :pending
                        'label-info'
                      when :exchanged
                        'label-success'
                      when :canceled
                        'label-default'
                      end
        content_tag(:span, exchange_code.state_name, class: "label #{label_class}")
      end
    end
  end
end
