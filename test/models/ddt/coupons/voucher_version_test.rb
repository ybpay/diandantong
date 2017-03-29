require "test_helper"
module Ddt
  class VoucherVersionTest < TestCase::Base
    include ItemableTest
    let(:itemable){ create :voucher_version }
    setup do
    end
  end
end