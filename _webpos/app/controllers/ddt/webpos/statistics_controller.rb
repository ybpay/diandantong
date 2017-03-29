module Ddt
  module Webpos
    class StatisticsController < Webpos::BaseController
      respond_to :json

      def product_sales
        @result = Ddt::Statistic::Product::SaleCount.new(branch_id: params[:branch_id], time_filter: params[:time_filter]).query
        render json: @result.to_json
      end

      def order_quantity
        @result = Ddt::Statistic::Order::Quantity.new(branch_id: params[:branch_id], time_filter: params[:time_filter]).query
        render json: Hash[@result.map {|k, v| [k, v] }]
      end
    end
  end
end
