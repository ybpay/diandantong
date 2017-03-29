module Ddt
  class Weixin::Cart::GrouponCartsController < WeixinApplicationController
    include Weixin::BaseCartController
    before_action :check_tuan, only: [:add_itemable]
    def add_tuan
      @cart.clear
      @tuan = @current_shop.abstract_coupon_versions.tuans.find(params[:tuan_id])
      if @tuan.can_receive_by?(@current_user)
        @cart.add(@tuan)
        render :show
      else
        render_error
      end
    end

    private

      def check_tuan
        itemable = OpenStruct.new(id: params[:itemable_id], itemable_type: params[:itemable_type])
        @tuan = @current_shop.abstract_coupon_versions.tuans.find_by(id: itemable.id)
        buy_num = @cart.line_items.of_itemable(itemable).count + 1
        if @tuan.blank? || !@tuan.can_receive_by?(@current_user, buy_num)
          render_error
          return
        end
      end

      def render_error
        render json: {errors: ["该团购券每个用户限购 #{@tuan.max_count_each_user}张"]}, status: :bad_request
      end

  end
end
