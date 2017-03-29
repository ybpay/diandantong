# encoding: utf-8
module Ddt
  class SystemAlipaysController < ActionController::Base

    def system_alipay_notify
      @service_product_order = Ddt::ServiceProductOrder.find(params[:service_product_order_id])

      # except :controller_name, :action_name, :host, etc.
      notify_params = params.except(*request.path_parameters.keys)
      Ddt::AlipayMethod.use_system_alipay
      if Alipay::Notify.verify?(notify_params)
        if @service_product_order.current_state == :new
          @service_product_order.verify!(notify_params)
        end
        render text: 'success'
      else
        render text: 'error'
      end
    end

  end
end
