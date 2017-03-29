require "test_helper"
module Ddt
  class GouponVersionTest < TestCase::Base
    include ItemableTest
    let(:itemable){ create :groupon_version }
    setup do
    end
  end
end