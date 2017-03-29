require 'test_helper'
module Ddt
  class StatisticHelperTest < TestCase::Base
    include Ddt::StatisticHelper


    def test_inc_rate
      assert_equal 0,   inc_rate(nil, nil)
      assert_equal 0,   inc_rate(nil, 100)
      assert_equal 100, inc_rate(100, nil)
      assert_equal 0,   inc_rate(0, 100)
      assert_equal 100, inc_rate(100, 0)
      assert_equal 0,   inc_rate(1, 1)
      assert_equal 50,  inc_rate(150, 100)
      assert_equal -50, inc_rate(50, 100)
      assert_equal 33.33, inc_rate(4, 3)
    end

    def test_rate
      assert_equal 0,   rate(nil, nil)
      assert_equal 0,   rate(nil, 100)
      assert_equal 100, rate(100, nil)
      assert_equal 0,   rate(0, 100)
      assert_equal 100, rate(100, 0)
      assert_equal 100, rate(100, 100)
      assert_equal 150, rate(150, 100)
      assert_equal 50,  rate(50, 100)
      assert_equal 33.33, rate(1, 3)
    end

    def test_avg
      assert_equal 0,   avg(nil, nil)
      assert_equal 0,   avg(nil, 100)
      assert_equal 0,   avg(100, nil)
      assert_equal 0,   avg(0, 100)
      assert_equal 0,   avg(100, 0)
      assert_equal 10,  avg(150, 15)
      assert_equal 0.5, avg(50, 100)
      assert_equal 0.33, avg(1, 3)
    end

    def test_sum
      assert_equal 0, sum([])
      assert_equal 0, sum([1,2,3])
      assert_equal 0, sum([{i: 1}, {i: 2}])
      assert_equal 3, sum([{i: 1}, {i: 2}], :i)
      assert_equal 3, sum([OpenStruct.new(i: 1), OpenStruct.new(i: 2)], :i)
      assert_equal 2, sum([OpenStruct.new(i: 1), OpenStruct.new(i: 2)]){|obj| obj.i > 1 ? obj.i : 0}
    end

  end
end
