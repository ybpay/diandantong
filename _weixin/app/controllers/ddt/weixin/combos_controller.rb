module Ddt
  class Weixin::CombosController < WeixinApplicationController
    respond_to :json
    before_action :set_combo, only: [:add_combo_package]

    def index
      @combos = @branch.combos
                       .of_wechat
                       .available
                       .on_shelf
                       .sale_on_now
                       .by_support_type(params[:order_type])
                       .includes(combo_items: :variants)
      fresh_when(@combos)
    end

    def add_combo_package
      @combo_package = @combo.add_combo_package(params[:combo_package][:items])
      if @combo_package.present?
        render :add_combo_package
      else
        render json: { errors: @combo.errors.full_messages }, status: :bad_request
      end
    end

    private

      def set_combo
        @combo = @branch.combos.find(params[:id])
      end

  end
end
