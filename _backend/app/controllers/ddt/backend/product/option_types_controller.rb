module Ddt
  class Backend::Product::OptionTypesController < Backend::BaseController
    check_permission :branch, :option_type
    before_action :set_option_type, only: [:show, :edit, :update, :destroy, :change_position]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/branch' }
    def index
      respond_to do |format|
        format.html do
          @option_types = @current_branch.option_types
        end
        format.json do
          @q = @current_branch.option_types.ransack(params[:q])
          @option_types = @q.result.distinct.paginate(page: params[:page])
          render :json => @option_types
        end
      end
    end

    def show

    end

    def new
      @option_type = @current_branch.option_types.new
    end

    def create
      @option_type = @current_branch.option_types.build(option_type_params)
      if @option_type.save
        render :reset
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @option_type.update(option_type_params)
        render :reset
      else
        render :update
      end
    end

    def destroy
      @option_type.destroy
      render :reset
    end

    def change_position
      @option_type.change_position(params[:position])
      render :reset
    end

    private
    def option_type_params
      params.require(:option_type).permit(:name, option_values_attributes: [:id, :name, :_destroy])
    end

    def set_option_type
      @option_type = @current_branch.option_types.find(params[:id])
    end
  end
end