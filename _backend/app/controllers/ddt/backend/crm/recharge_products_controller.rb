module Ddt
  module Backend
    module Crm
      class RechargeProductsController < Backend::BaseCrmController
        check_permission :shop, :recharge_product
        before_action :set_recharge_product, only: [:show, :edit, :update, :destroy]

        def index
          @q = @current_shop.recharge_products.ransack(params[:q])
          @recharge_products = @q.result(distinct: true).paginate(page: params[:page])
        end

        def show
        end

        def new
          @recharge_product = @current_shop.recharge_products.build
        end

        def edit
        end

        def create
          @recharge_product = @current_shop.recharge_products.build(recharge_product_params)
          if @recharge_product.save
            render :show
          else
            render json: { errors: @recharge_product.errors.full_messages }, status: :bad_request
          end
        end

        def update
          if @recharge_product.update(recharge_product_params)
            render :show
          else
            render json: { errors: @recharge_product.errors.full_messages }, status: :bad_request
          end
        end

        def destroy
          if @recharge_product.destroy
            render json: {}
          else
            render json: { errors: @recharge_product.errors.full_messages }, status: :bad_request
          end
        end

        private
          def set_recharge_product
            @recharge_product = @current_shop.recharge_products.find(params[:id])
          end

          def recharge_product_params
            params.require(:recharge_product).permit(:name, :price, :recharge_amount, :extra_credits, :first_recharge_available_amount, :support_all_branch, :branch_ids_string, :branch_group_ids_string)
          end
      end
    end
  end
end
