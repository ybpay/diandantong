# encoding: utf-8
module Ddt
  class ShortMessageRecharge < Ddt::ServiceProduct

    # 短信充值数量
    preference :recharge_count, :integer

    def perform(shop)
      recharge_count = self.preferred_recharge_count
      if recharge_count > 0
        shop.recharge_short_messages(recharge_count)
      else
        raise "recharge_count must greater than 0"
      end
    end

  end
end
