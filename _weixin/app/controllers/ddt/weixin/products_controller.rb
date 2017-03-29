module Ddt
  class Weixin::ProductsController < WeixinApplicationController
    before_action :set_product, only: [:show]
    def index
      @products = @branch.products
                         .of_wechat
                         .available
                         .sale_on_now
                         .on_shelf
                         .where(estimate_clear: false)
                         .by_support_type(params[:order_type])
                         .includes(:tag_relations, :tags, :variants_including_master, :variants, :master)
      if params[:name].present?
        @products = @products.includes(:categories).by_name(params[:name])
      else
        if params[:category_id].blank?
          category = @branch.categories.root.by_support_type(params[:order_type]).first
          @products = @products.by_category(category.try(:id))
        else
          @products = @products.by_category(params[:category_id])
        end
      end
      fresh_when(@products)
    end

    def show

    end

    private
    def set_product
      @product = @branch.products.find(params[:id])
    end

  end
end
