module Ddt
  class Promotion
    module Events
      class OrderPay < ::Ddt::PromotionEvent
        belongs_to_order
        set_from :order, targets: [:user, :shop, :branch]
      end
    end
  end
end