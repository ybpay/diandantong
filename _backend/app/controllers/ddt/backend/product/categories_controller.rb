module Ddt
  class Backend::Product::CategoriesController < Backend::BaseController
    check_permission :branch, :category, base_permission_actions.merge({[:update_products, :products_actions] => :update})
    before_action :set_category, only: [:show, :edit, :update, :destroy, :products_actions, :update_products]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/product' }
    def index
      respond_to do |format|
        format.html do
          @categories = @current_branch.categories.root
        end
        format.json do
          @q = @current_branch.categories.ransack(params[:q])
          @categories = @q.result.distinct.paginate(page: params[:page])
          render :json => @categories.map(&:select_json)
        end
      end
    end

    def show
    end

    def new
      @category = @current_branch.categories.build(parent_id: params[:parent_id])
      respond_to do |format|
        format.js
      end
    end

    def edit
      respond_to do |format|
        format.js
      end
    end

    def create
      @category = @current_branch.categories.build(category_params)
      respond_to do |format|
        format.js do
          if @category.save
            render :create
          else
            render :new
          end
        end
      end
    end

    def update
      if @category.update(category_params)
        @category.change_position(params[:position])
        render :update
      else
        render :edit
      end
    end

    def destroy
      @destroy_success = @category.destroy
      respond_to do |format|
        format.js
      end
    end

    def products_actions
      respond_to do |format|
        format.js
      end
    end

    def update_products
      product_params = params.permit(:enable_discount)
      @category.update_products(product_params)
      respond_to do |format|
        format.js
      end
    end

    private
      def set_category
        @category = @current_branch.categories.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :parent_id, :show_on_wechat, :support_delivery, :support_reservation, :support_eat_in_hall)
      end
  end
end
