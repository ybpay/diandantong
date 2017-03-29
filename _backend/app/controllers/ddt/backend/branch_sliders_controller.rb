module Ddt
  class Backend::BranchSlidersController < Backend::BaseController
    check_permission :shop, :wechat_config, { [:index, :show] => :show, [:change_position, :new, :create, :edit, :update, :destroy] => :update}
    before_action :set_branch_slider, only: [:show, :edit, :update, :destroy, :change_position]

    def index
      @q = @current_shop.branch_sliders.ransack(params[:q])
      @branch_sliders = @q.result(distinct: true).paginate(page: params[:page])
    end

    def change_position
      @branch_slider.change_position(params[:position])
      respond_to do |format|
        format.js { render :reset}
      end
    end

    def show
    end

    def new
      @branch_slider = @current_shop.branch_sliders.build
    end

    def edit
    end

    def create
      @branch_slider = @current_shop.branch_sliders.build(branch_slider_params)

      if @branch_slider.save
        redirect_to backend_shop_branch_slider_path(@current_shop, @branch_slider), notice: "创建成功"
      else
        render action: 'new'
      end
    end

    def update
      if @branch_slider.update(branch_slider_params)
        redirect_to backend_shop_branch_slider_path(@current_shop, @branch_slider), notice: "更新成功"
      else
        render action: 'edit'
      end
    end

    def destroy
      @branch_slider.destroy
      redirect_to backend_shop_branch_sliders_url(@current_shop)
    end

    private
    def set_branch_slider
      @branch_slider = @current_shop.branch_sliders.find(params[:id])
    end

    def branch_slider_params
      params.require(:branch_slider).permit(:img, :img_cache, :url, :position)
    end
  end
end
