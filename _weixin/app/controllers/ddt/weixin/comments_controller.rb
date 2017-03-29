module Ddt
  class Weixin::CommentsController < WeixinApplicationController
    respond_to :json
    def index
      @comments = @branch.branch_comments.of_published
    end

    def create
      @current_order = @current_shop.base_orders.find(comment_params[:order_id])
      if @current_order.comment
        render json: {errors: t('order has already commented, do not recomment it')}, status: :bad_request
      else
        @comment = @current_order.build_comment(comment_params)
        @comment.branch = @current_order.branch
        @comment.owner = @current_user
        if @comment.save
          render json: {}
        else
          render json: { errors: @comment.errors.full_messages }, status: :bad_request
        end
      end
    end

    private
    def comment_params
      params.require(:guest_queue).permit(:content, :rating)
    end
  end
end
