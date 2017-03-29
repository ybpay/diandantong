module Ddt
  class Backend::TagsController < Backend::BaseController
    check_permission :branch, :tag, {index: :show, [:edit, :update] => :update, destroy: :destroy}
    before_action :set_tag, only: [:edit, :destroy, :update]
    layout 'ddt/layouts/backend/branch'

    def index
      @q = (@current_branch || @current_shop).all_tags.ransack(params[:q])
      @tags = @q.result.distinct.paginate(page: params[:page])
      respond_to do |format|
        format.html
        format.json {
          render :json => @tags.map(&:tag_json)
        }
      end
    end

    def edit
    end

    def destroy
      @tag.destroy
      respond_to do |format|
        format.js { render 'remove_tr'}
      end
    end

    def update
      if @tag.update(tag_params)
        render 'reset_tr'
      else
        render :edit
      end
    end

    private

    def set_tag
      @tag = @current_branch.all_tags.find(params[:id])
    end

  end
end
