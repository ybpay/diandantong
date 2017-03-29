module Ddt
  module Backend
    module Payment
      class WechatpayMethodV336sController < WechatpayMethodsController
        def switch_version
          set_payment_method
          @payment_method.active = false
          @payment_method.save!
          redirect_to url_for([:edit, :backend, @current_shop, :wechatpay_method_legacies])
        end
      end
    end
  end
end
