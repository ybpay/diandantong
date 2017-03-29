module Ddt
  class Backend::OnePagesController  < Backend::BaseController
    check_permission :shop, :wechat_config, {[:index, :show] => :show, [:new, :edit, :create, :update, :destroy, :change_position] => :update}
    before_action :set_one_page, only: [:show, :edit, :update, :destroy, :change_position]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/shop' }
    respond_to :html

    def index
      @q = @current_shop.one_pages.ransack(params[:q])
      @one_pages = @q.result(distinct: true).paginate(page: params[:page])
      respond_with(@one_pages)
    end

    def show
      respond_with(@one_page)
    end

    def new
      @one_page = @current_shop.one_pages.build
      respond_with(@one_page)
    end

    def edit
    end

    def create
      @one_page = @current_shop.one_pages.build(one_page_params)
      if @one_page.save
        redirect_to [:backend, @current_shop, @one_page], notice: '创建成功'
      else
        render action: 'new'
      end
    end

    def update
      if @one_page.update(one_page_params)
        redirect_to [:backend, @current_shop, @one_page], notice: '更新成功'
      else
        render action: 'edit'
      end
    end

    def destroy
      @one_page.destroy
      redirect_to [:backend, @current_shop, :one_pages], notice: "删除成功"
    end

    def change_position
      @one_page.change_position(params[:position])
      respond_to do |format|
        format.js { render :reset }
      end
    end

    private
      def set_one_page
        @one_page = @current_shop.one_pages.find(params[:id])
      end

      def one_page_params
        params.require(:one_page).permit(:image, :abstract, :position, :alignment, :remove_image, :image_cache)
      end
  end
end
