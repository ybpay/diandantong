# encoding:utf-8
module Ddt
  class PayMethodSetting < Base

    include BelongsToShop
    belongs_to :branch, class_name: 'Ddt::Branch', touch: true
    scope :in_shop, ->{ where(branch_id: nil)}
    scope :in_branch, ->{ where.not(branch_id: nil)}
    set_shop_from :branch
    #boolean :can_credits_deduction , default: true
    #boolean :can_card_deduction    , default: true
    #boolean :can_pay_on_face       , default: true
    #boolean :can_pay_on_arrive     , default: true
    #boolean :can_pay_on_receive    , default: true
    #boolean :can_alipay            , default: true
    #boolean :can_wechatpay         , default: true
    #boolean :can_baidupay          , default: true
    #boolean :can_vip_card_pay      , default: false
    #boolean :can_bank_card_pay      , default: false
  end
end
