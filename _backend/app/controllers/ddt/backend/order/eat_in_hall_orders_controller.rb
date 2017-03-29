module Ddt
  class Backend::Order::EatInHallOrdersController < Backend::BaseController
    include Backend::BaseOrderController
    check_permission :branch, :order, {
      [:show, :other_msg] => :show,
      :confirm => :confirm,
      :complete => :complete,
      :cancel => :cancel,
      [:get_reprint, :chooseable_printers, :reprint] => :reprint,
      [:pay_by_default_method] => :settle,
      [:get_append_pay_item, :append_pay_item, :destroy_pay_item, :clear_appended] => :append_pay_item,
    }
  end
end
