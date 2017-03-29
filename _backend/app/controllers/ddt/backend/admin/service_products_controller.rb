module Ddt
  class Backend::Admin::ServiceProductsController < Backend::BaseAdminController
    before_action :set_service_product, only: [:show, :edit, :update, :destroy]

    def index
      @service_products = ServiceProduct.all
    end

    def show
    end

    def new
      @service_product = ServiceProduct.new
    end

    def create
      @service_product = ServiceProduct.new(service_product_params)
      @service_product.set_preferences_converted(preferences_params)
      if @service_product.save
        redirect_to backend_service_product_path(@service_product), notice: 'Service product was successfully created.'
      else
        render 'new'
      end
    end

    def edit
    end

    def update
      @service_product.set_preferences_converted(preferences_params)
      if @service_product.update(service_product_params)
        redirect_to backend_service_product_path(@service_product), notice: 'Service product was successfully updated.'
      else
        render 'edit'
      end
    end

    def destroy
      @service_product.destroy
      redirect_to backend_service_products_path
    end

    def change_position
      @service_products = ServiceProduct.all
      if params[:service_product_ids].size != 2
        @errors = "需要提供进行排序的服务套餐"
      else
        updated_service_products = @service_products.find(params[:service_product_ids])
        @first = updated_service_products[0]
        @second = updated_service_products[1]
        position = @second.position
        @second.position = @first.position
        @first.position = position
        ServiceProduct.transaction do
          if !@first.save
            @errors = @first.errors.full_messages
            raise ActiveRecord::Rollback
          end
          if !@second.save
            @errors = @second.errors.full_messages
            raise ActiveRecord::Rollback
          end
        end
      end
      redirect_to backend_service_products_path
    end

    def change_preferences
      @preferences = ServiceProduct.default_preferences_for(params[:type])
      respond_to do |format|
        format.js
      end
    end

    private
    def service_product_params
      params.require(:service_product).permit(:subject, :type, :price, :description, :is_offline)
    end

    def preferences_params
      # 把键都转化为符号
      Hash[params[:preferences].map { |k, v| [k.to_sym, v]}] if params[:preferences]
    end

    def set_service_product
      @service_product = ServiceProduct.find(params[:id])
    end

  end
end
