require 'test_helper'
module Ddt
  class CncityTest < TestCase::Base

    def test_not_suffix_when_not_match
      assert_equal '', Cncity.suffix('广北')
      assert_equal '', Cncity.suffix('广北', '佛山')
      assert_equal '广东省', Cncity.suffix('广东', '砂头')
    end

    def test_suffix_zhi_xia_shi
      assert_equal '北京市', Cncity.suffix('北京')
      assert_equal '北京市', Cncity.suffix('北京', '北京')
    end

    def test_suffix_province
      assert_equal '广东省', Cncity.suffix('广东')
      assert_equal '陕西省', Cncity.suffix('陕西')
      assert_equal '广西壮族自治区', Cncity.suffix('广西')
    end

    def test_suffix_province_and_city
      assert_equal '广东省-佛山市', Cncity.suffix('广东', '佛山')
    end

    def test_suffix_province_and_city_and_region
      assert_equal '广东省-汕头市-龙湖区', Cncity.suffix('广东', '汕头', '龙')
    end

  end
end
