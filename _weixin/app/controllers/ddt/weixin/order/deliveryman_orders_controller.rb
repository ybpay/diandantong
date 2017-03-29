module Ddt
  class Weixin::Order::DeliverymanOrdersController < WeixinApplicationController
    before_action :set_account, only: [:index]

    def index
      order_params = {placed_at: :desc}
      temp_result = []
      if params[:assign].present?
        temp_result = @current_shop.delivery_orders.order(order_params)
          .where(branch_id: @account.managed_branch_ids)
          .where(delivery_man_id_eq: @account.id)
          .where(created_at: 3.days.ago..Time.now)
          .where(state: ['pending', 'confirmed'])
          .where(params[:q]).paginate(page: params[:page], per_page: (params[:per_page] || 20))
      else
        temp_result = @current_shop.delivery_orders.order(order_params)
          .where(branch_id: @account.managed_branch_ids)
          .where(delivery_man_id_null: true)
          .where(created_at: 3.days.ago..Time.now)
          .where(state: ['pending', 'confirmed'])
          .where(params[:q]).paginate(page: params[:page], per_page: (params[:per_page] || 20))
      end
      @orders = []
      temp_result.each do |order| 
        @orders << order if (order.is_paid? || order.pay_items.any?{|pay_item| pay_item.pay_on_receive?})
      end
      render file: '/ddt/weixin/user/order/delivery_orders/index.json.jbuilder'
    end

    private

      def set_account
        @account = @current_user.account_user
        if @account.blank?
          render json: {errors: '您无权利访问该页面'}, status: :bad_request
          return
        end
      end

  end
end
