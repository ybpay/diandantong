require "test_helper"
module Ddt
  module Weixin
    class ShopsControllerTest < TestCase::Controller::Weixin
      def test_show
        Ddt::WechatAccount.any_instance.stubs(:get_jsapi_ticket).returns("jsapi_ticket")
        get :show, p(format: :html)
        assert_response 200
      end
    end
  end
end