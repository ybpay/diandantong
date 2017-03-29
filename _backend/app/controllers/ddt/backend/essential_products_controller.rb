module Ddt
  class Backend::EssentialProductsController < Backend::BaseController
    check_permission :branch, :essential_product
    before_action :set_essential_product, only: [:show, :edit, :update, :destroy]
    layout 'ddt/layouts/backend/branch'

    def index
      @q = @current_branch.essential_products.ransack(params[:q])
      @essential_products = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def new
      @essential_product = @current_branch.essential_products.build
    end

    def create
      @essential_product = @current_branch.essential_products.build(essential_product_params)
      if @essential_product.save
        redirect_to backend_shop_branch_essential_products_url(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/essential_product')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @essential_product.update(essential_product_params)
        redirect_to [:backend, @current_shop, @current_branch, :essential_products], notice: "#{t('activerecord.models.ddt/essential_product')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @essential_product.destroy
        redirect_to backend_shop_branch_essential_products_url(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/essential_product')} 删除成功."
      else
        flash[:error] = @essential_product.errors.full_messages.join('<br/>')
        redirect_to backend_shop_branch_essential_products_url(@current_shop, @current_branch)
      end
    end

    private

    def set_essential_product
      @essential_product = @current_branch.essential_products.find(params[:id])
    end

    def essential_product_params
      params.require(:essential_product).permit(:variant_id, :quantity, :per_guest, :order_type)
    end
  end
end
