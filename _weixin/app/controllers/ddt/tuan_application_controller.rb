module Ddt
  class TuanApplicationController < Ddt::BaseWeixinController
    check_feature :weixin
    layout false
  end
end
