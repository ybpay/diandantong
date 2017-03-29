module Ddt
  module Backend
    module Branch
      class PayMethodSettingsController < ::Ddt::Backend::BaseController
        check_permission :branch, :pay_method, {index: :show, update_all: :update}
        layout 'ddt/layouts/backend/branch'
        before_action :set_branch
        def index
        end

        def update_all
          @branch.update(branch_params)
          redirect_to [:backend, @current_shop, @branch, :pay_method_settings], notice: '修改成功'
        end

        private
        def set_branch
          @branch = @current_shop.branches.find(params[:branch_id])
        end
        def branch_params
          params.require(:branch).permit({
            delivery_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            eat_in_hall_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            fastfood_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            groupon_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            reservation_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
            payment_pay_method_setting_attributes: [:can_credits_deduction, :can_card_deduction, :can_pay_on_face, :can_pay_on_arrive, :can_pay_on_receive, :can_alipay, :can_wechatpay, :can_baidupay, :can_vip_card_pay, :can_bank_card_pay],
          })
        end
      end
    end
  end
end
