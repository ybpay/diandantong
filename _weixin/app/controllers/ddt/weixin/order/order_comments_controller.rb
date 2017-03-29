module Ddt
  class Weixin::Order::OrderCommentsController < WeixinApplicationController

    # TODO
    def show
    end

    def create
      order = @current_user.orders.find(params[:order_id])
      if order.comment
        render json: {errors: t('order has already commented, do not recomment it')}, status: :bad_request
      else
        comment = order.create_comment(comment_params.merge(
          branch: order.branch,
          owner: @current_user,
          commentable_type: "Ddt::Order",
          commentable_id: order.id
        ))
        if comment.valid?
          render json: {}
        else
          render json: { errors: comment.errors.full_messages }, status: :bad_request
        end
      end
    end

    private
    def comment_params
      params.require(:order_comment).permit(:content, :rating)
    end

  end
end
