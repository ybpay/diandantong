require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Order
      class RechargeTest < TestCase::Base
        include OrderService::Order::BaseTest
        let(:itemable){ create :recharge_product, shop: shop }
        let(:order){ example_recharge_order }

        def test_apply_recharge
          order.pay_by_default_method
          user.reload
          assert_equal user.card_wallet.amount, 120
          assert user.vip_info.first_recharge_at.present?
          assert_equal user.vip_info.first_recharge_limited_amount, 20
          assert_equal user.vip_info.available_card_wallet_amount, 100
        end
      end
    end
  end
end