module Ddt
  module CommonApi
    module V1
      class CombosController < V1::BaseController

        def index
          unless params[:with_all]
            @combos = @current_branch.combos
                                   .available
                                   .sale_on_now
                                   .on_shelf
                                   .by_support_type(params[:order_type])
                                   .includes(:images, combo_items: :variants)
                                   .ransack(params[:q]).result
          else
            @combos = @current_branch.combos.ransack(params[:q]).result
          end
          fresh_when(@combos)
        end

        def show
          @combo = @current_branch.combos.find(params[:id])
        end

        def update
          @combo = @current_branch.combos.find(params[:id])
          if @combo.update(combo_params)
            render :show
          else
            render json: { errors: @combo.errors.full_messages }, status: :bad_request
          end
        end

        # params: {
        #   combo_package: [{ combo_item_id, variant_id, quantity }]
        # }
        def add_combo_package
          @combo = @current_branch.combos.find(params[:id])
          @combo_package = @combo.add_combo_package(params[:combo_package])
          if @combo_package
            render :add_combo_package
          else
            render json: { errors: @combo.errors.full_messages }, status: :bad_request
          end
        end

        private

        def combo_params
          params.require(:combo).permit(:name, :on_shelf)
        end

      end
    end
  end
end
