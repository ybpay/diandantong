module Ddt
  class Weixin::OrderItemablesController < WeixinApplicationController
    respond_to :json
    before_action :set_table
    before_action :set_order_itemable, only: [:plus, :minus]
    def index
      if @current_user.wifi_code
        session[:table_id] = params[:table_id]
        @current_user.order_itemables.each do |order_itemable|
          order_itemable.update(table_id: params[:table_id])
        end
        @merge_order_itemables_groups = @current_user.order_itemables.for_wifi_order.sort{|a, b| b.base_user_id.to_i - a.base_user_id.to_i}.group_by{|itemable| itemable.base_user_id }
      else
        @merge_order_itemables_groups = @table.order_itemables.for_merge_order.sort{|a, b| b.base_user_id.to_i - a.base_user_id.to_i}.group_by{|itemable| itemable.base_user_id }
      end
    end

    def plus
      @order_itemable.plus
      render :show
    end

    def minus
      @order_itemable.minus
      render :show
    end

    private
    def set_table
      @table = @branch.tables.find(params[:table_id])
    end

    def set_order_itemable
      @order_itemable = @table.order_itemables.find_by(id: params[:id])
      if @order_itemable.blank?
        render json: {errors: '该菜品已被好友退掉, 请刷新购物车。'}, status: :bad_request
        return
      end
    end
  end
end
