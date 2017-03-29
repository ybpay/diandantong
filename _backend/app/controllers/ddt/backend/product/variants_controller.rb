module Ddt
  class Backend::Product::VariantsController < Backend::BaseController
    check_permission :branch, :product, base_permission_actions.merge({[:remove_estimate_clear, :add_estimate_clear, :ajax_estimate_clear_reciprocal, :add_estimate_clear_reciprocal] => :estimate_clear})
    before_action :set_product
    before_action :check_product_option_type_count, only: [:new, :create, :edit, :update]
    before_action :set_variant, only: [:show, :edit, :update, :destroy, :change_position ,:remove_estimate_clear , :add_estimate_clear , :ajax_estimate_clear_reciprocal ,:add_estimate_clear_reciprocal ]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/product' }
    def index
      @variants = @product.variants
    end

    def show

    end

    def new
      @variant = @product.variants.new
    end

    def create
      @variant = @product.variants.build(variant_params)
      if @variant.save
        render :reset
      else
        render :new
      end
    end

    def edit

    end

    def update
      if @variant.update(variant_params)
        render :reset
      else
        render :edit
      end
    end

    def destroy
      @variant.destroy
      render :reset
    end

    def change_position
      @variant.change_position(params[:position])
      render :reset
    end

    def remove_estimate_clear
      if @variant.remove_estimate_clear
        redirect_to [:backend, @current_shop, @current_branch, :products],notice: "子产品: #{@variant.name_with_options_text} 成功去除估清,并且库存加满为: 999"
      else
        flash[:error] = @variant.errors.full_messages if @variant.errors.present?
        redirect_to [:backend, @current_shop, @current_branch, :products]
      end
    end

    def add_estimate_clear
      if @variant.add_estimate_clear
        redirect_to [:backend, @current_shop, @current_branch, :products] ,notice: "子产品: #{@variant.name_with_options_text} 成功估清!"
      else
        flash[:error] = @variant.errors.full_messages if @variant.errors.present?
        redirect_to [:backend, @current_shop, @current_branch, :products]
      end
    end

    def ajax_estimate_clear_reciprocal
      render :add_estimate_clear_reciprocal
    end
    def add_estimate_clear_reciprocal
      if params[:variant][:stock_quantity].to_i > 0 &&  @variant.add_estimate_clear_reciprocal(params[:variant][:stock_quantity].to_i)
        redirect_to [:backend, @current_shop, @current_branch, :products] ,notice: "子产品: #{@variant.name_with_options_text} 成功数量估清! 份额为: #{params[:stock_quantity]}"
      else
        flash[:error] = "子产品: #{@variant.name_with_options_text} 数量估清 失败,请填写正确的数字"
        redirect_to [:backend, @current_shop, @current_branch, :products]
      end
    end

    private
    def variant_params
      params.require(:variant).permit(:name, :price, :vip_price, :stock_quantity, :sale_quantity, :sku, :nfc_code, :by_weight, :default_weight, :estimate_clear,
                                      :option_value_ids => [])
    end

    def set_product
      @product = @current_branch.products.find(params[:product_id])
    end

    def check_product_option_type_count
      if @product.option_types.count == 0
        render :no_option_type
      end
    end

    def set_variant
      @variant = @product.variants.find(params[:id])
    end

  end
end
