require "test_helper"
module Ddt
  class MolingUtilTest < TestCase::Base
    def test_erase
      assert_equal 134.452, MolingUtil.erase(134.452, -2)
      assert_equal 134,     MolingUtil.erase(134.452, 0)
      assert_equal 130,     MolingUtil.erase(134.452, -1)
      assert_equal 134,     MolingUtil.erase(134.452, 0)
      assert_equal 134.4,   MolingUtil.erase(134.452, 1)
    end

    def test_round
      assert_equal 130,     MolingUtil.round(134.452, -1)
      assert_equal 134.452, MolingUtil.round(134.452, 3)
      assert_equal 134,     MolingUtil.round(134.452, 0)
      assert_equal 135,     MolingUtil.round(134.552, 0)
      assert_equal 134.4,   MolingUtil.round(134.442, 1)
      assert_equal 134.5,   MolingUtil.round(134.452, 1)
      assert_equal 134.45,  MolingUtil.round(134.452, 2)
    end

  end
end
