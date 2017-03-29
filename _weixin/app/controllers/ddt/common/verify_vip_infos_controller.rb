#encoding: utf-8
module Ddt
  class Common::VerifyVipInfosController < CommonApplicationController
    before_filter :set_order

    def show
      if ! @order.present?
        @message = '参数出错'
      elsif @order.current_vip.blank? and @current_user.vip?
        @message = '点击按钮进行授权'
      elsif @order.current_vip.blank?
        @message = '请先申请会员'
        @user_vip_info_url = Ddt::LinkResource.new(shop: @current_shop).user_vip_info_url
      else
        @message = '订单已经绑定会员信息'
      end
      render "ddt/weixin/verify/vip_info"
    end

    def verify
      validate_user_info
      if validate_parameters(params)
        if @order.current_vip.blank? && @current_user.vip?
          @order.change_vip_info(@current_user.vip_info)
          @success = true
        else
          @message = '您不是会员或订单已经绑定会员'
        end
      else
        @message = '参数校验失败'
      end
      render "ddt/weixin/verify/vip_info"
    end

    private

    def validate_parameters(params)
      if @order.present? && params[:hash].present? && @order.waiter.present?
        token = AccessToken.valid.where(
            holder: @order.waiter
        ).find { |it|
          # 如果该用户 24 小时内登陆次数过多，可能会悲剧
          Digest::MD5.hexdigest(it.access_token) == params[:hash]
        }
        if token.present?
          return true
        end
      end
      return false
    end

    def set_order
      order_id = params[:order_id]
      @order = @current_shop.orders.find_by(id: order_id)
    end

  end
end