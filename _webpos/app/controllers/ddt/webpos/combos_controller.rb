module Ddt
  module Webpos
    class CombosController < Webpos::BaseController
      def index
        @combos = @current_branch.combos.available.sale_on_today.on_shelf.includes(combo_items: :variants)
        fresh_when(@combos)
      end

      def add_combo_package
        @combo = @current_branch.combos.find(params[:id])
        @combo_package = @combo.add_combo_package(params[:combo_package])
        if @combo_package
          render :add_combo_package
        else
          render json: { errors: @combo.errors.full_messages }, status: :bad_request
        end
      end

    end
  end
end
