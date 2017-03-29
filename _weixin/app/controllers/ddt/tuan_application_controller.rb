module Ddt
  class TuanApplicationController < Ddt::BaseWeixinController
    check_feature :weixin
    layout 'ddt/layouts/tuan'
  end
end
