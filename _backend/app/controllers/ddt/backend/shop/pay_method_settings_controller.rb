module Ddt
  module Backend
    module Shop
      class PayMethodSettingsController < ::Ddt::Backend::BaseController
        check_permission :shop, :pay_method, {index: :show, update_all: :update}
        layout 'ddt/layouts/backend/shop'
        def index
        end

        def update_all
          @current_shop.update(shop_params)
          redirect_to [:backend, @current_shop, :pay_method_settings], notice: '修改成功'
        end

        private
        def shop_params
          params.require(:shop).permit({
            delivery_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            eat_in_hall_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            fastfood_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            groupon_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            reservation_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            recharge_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            payment_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
          })
        end
      end
    end
  end
end
