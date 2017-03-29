module Ddt
  class Weixin::Cart::FastfoodCartsController < WeixinApplicationController
    include Weixin::BaseCartController
    include Weixin::BaseCartCouponController
  end
end
