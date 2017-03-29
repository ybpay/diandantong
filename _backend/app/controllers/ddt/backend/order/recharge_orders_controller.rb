module Ddt
  class Backend::Order::RechargeOrdersController < Backend::BaseController
    include Backend::BaseOrderController
    check_permission :shop, :recharge_order, {
      [:show, :other_msg] => :show,
      :cancel => :cancel,
      [:get_reprint, :chooseable_printers, :reprint] => :reprint,
      [:pay_by_default_method, :confirm, :complete] => :settle,
      [:get_append_pay_item, :append_pay_item, :destroy_pay_item, :clear_appended] => :settle,
    }
  end
end
