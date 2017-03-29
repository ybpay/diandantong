module Ddt
  module CommonApi
    module V1
      class ProductsController < V1::BaseController
        before_action :set_product, only: [:update]
        check_permission :branch, :product, { index: :show, update: :update }

        def index
          @filter_in_client = params[:filter_in_client] == true
          if @filter_in_client
            @q = @current_branch.products.available.sale_on_today.includes(:variants_including_master).ransack(params[:q])
          else
            @q = @current_branch.products.available.sale_on_now.on_shelf.includes(:variants_including_master).ransack(params[:q])
          end
          if params[:no_paginate]
            @products = @q.result
          else
            @products = paginate @q.result
          end
          fresh_when(@products)
        end

        def update
          options = product_params
          variants_including_master_attributes = options.delete(:variants)
          options[:variants_including_master_attributes] =  variants_including_master_attributes

          if @product.update(options)
            render :show
          else
            render json: {errors: @product.errors.full_messages}, status: :bad_request
          end
        end


        private
        def product_params
          params.require(:product).permit(:name, :description, :estimate_clear, :on_shelf, :unit_name, :show_note_in_weixin,
            :variants => [:id, :price, :vip_price, :by_weight, :default_weight, :stock_quantity, :is_master])
        end

        def set_product
          @product = @current_branch.products.find(params[:id])
        end

      end
    end
  end
end
