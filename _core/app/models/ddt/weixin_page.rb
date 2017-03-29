# encoding: utf-8
module Ddt
  class WeixinPage < Ddt::Base
    include BelongsToShop
    replicated_model

    acts_as_type :template_type, [:'/my/shop/my.html'], %W[会员首页]
  end
end
