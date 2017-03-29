require "test_helper"
module Ddt
  module CommonApi
    module V1
      class CreditsWalletsControllerTest < TestCase::Controller::CommonApi

        def test_recharge
          amount_was = vip_user.vip_info.credits_wallet.amount
          post :recharge, p(vip_info_id: vip_user.vip_info.id, recharge: {amount: 20, note: ''})
          assert_response 200
          assert_equal 20, json["credits_wallet_amount"] - amount_was
        end

        def test_exchange
          amount_was = vip_user.vip_info.credits_wallet.amount
          post :exchange, p(vip_info_id: vip_user.vip_info.id, exchange: {amount: 20, note: ''})
          assert_response 200
          assert_equal 20, amount_was - json["credits_wallet_amount"]
        end

      end
    end
  end
end
