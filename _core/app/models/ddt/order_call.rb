# encoding:utf-8
module Ddt
  class OrderCall < Ddt::Base
    COST_PER_MINUTE = 0.1 # 每分钟的价格
    include BelongsToBranch
    belongs_to_order
    set_from :order

    validates_presence_of :to, :call_sid
    # state 0正常通话 1被叫通话未应答  2外呼失败
    # duration user_data text

    def self.create_call(order_id)
      order = OrderService::Order::Base.find(order_id)
      shop = order.shop
      if shop.call_setting.can_order_call?
        branch = order.branch
        resp_url = URI.join(Rails.application.routes.url_helpers.ddt_url, "common/cloopen_call_resp").to_s
        call_sid = Ddt::Cloopen.landing_call(branch.phone, resp_url: resp_url)
        if call_sid
          order.order_calls.create(to: branch.phone, call_sid: call_sid)
        end
      end
    end

    def set_state(state, duration)
      ActiveRecord::Base.transaction do
        self.update(state: state, duration: duration)
        cost_amount = (duration / 60.0).ceil * COST_PER_MINUTE
        self.shop.call_setting.cost(cost_amount)
      end
      # 呼叫失败1分钟后重试一次
      if !self.success? && self.order.order_calls.count == 1
        OrderCallWorker.perform_in(1.minute, self.order_id)
      end
    end

    def success?
      state == 0
    end

  end
end