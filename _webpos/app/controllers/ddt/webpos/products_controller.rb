module Ddt
  module Webpos
    class ProductsController < Webpos::BaseController
      def index
        @q = @current_branch
                 .products
                 .available
                 .sale_on_today
                 .includes(:categories, :variants, :master)
                 .ransack(params[:q])
        if params[:no_paginate]
          @products = @q.result
        else
          @products = @q.result.paginate(page: params[:page], per_page: (params[:per_page] || 20), total_entries: 100)
        end
        fresh_when(@products)
      end
    end
  end
end
