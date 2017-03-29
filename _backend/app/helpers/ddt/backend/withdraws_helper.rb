# encoding: utf-8
module Ddt
  module Backend
    module WithdrawsHelper
      def state_class_name(state)
        case state
        when 'frozen' then 'label-info'
        when 'completed' then 'label-success'
        when 'canceled' then 'label-warning'
        end
      end
    end
  end
end
