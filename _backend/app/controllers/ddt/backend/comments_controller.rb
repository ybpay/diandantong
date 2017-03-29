module Ddt
  class Backend::CommentsController < Backend::BaseController
    check_permission :branch, :comment, { index: :show, [:reply, :create] => :reply, update: :update}
    before_action :set_comment, only: [:update, :reply]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/branch' }
    def index
      @q = @current_branch.branch_comments.ransack(params[:q])
      @comments = @q.result.paginate(page: params[:page])
    end

    def reply
      @reply_comment = Ddt::Comment.new
      @reply_comment.commentable = @comment
    end

    def create
      @comment = @current_branch.branch_comments.find(comment_params[:commentable_id])
      @reply_comment = @comment.build_comment(comment_params)
      @reply_comment.owner = @current_account
      @reply_comment.branch = @current_branch
      @reply_comment.shop = @current_shop
      if @reply_comment.save
        render :replace_tr
      else
        render :reply
      end
    end

    def update
      if @comment.update(comment_params)
        render :replace_tr
      else
        render :index
      end
    end


    private
      def set_comment
        @comment = @current_branch.branch_comments.find(params[:id])
      end

      def comment_params
        params.require(:comment).permit(:commentable_type, :commentable_id, :content, :state )
      end
  end
end
