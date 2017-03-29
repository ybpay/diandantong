module Ddt
  module InnerApi
    class ShopsController < InnerApi::BaseController
      before_action :set_shop, only: [:show]
      def index
        @q = Ddt::Shop.all.ransack(params[:q])
        @shops = @q.result.paginate(page: params[:page], per_page: (params[:per_page] || 5))
      end

      def show
      end

      private
      def set_shop
        @shop = Ddt::Shop.find(params[:id])
      end
    end
  end
end
