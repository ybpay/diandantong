require "test_helper"
module Ddt
  class RechargeProductTest < TestCase::Base
    include ItemableTest
    let(:itemable){ create(:recharge_product) }
    setup do
    end
  end
end