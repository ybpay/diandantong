module Ddt
  class Weixin::CategoriesController < WeixinApplicationController
    respond_to :json
    def index
      @all_categories = @branch.categories.show_on_wechat.by_support_type(params[:support_type])
      count_products
      fresh_when(@categories)
    end

    private

      def count_products
        if @all_categories.blank?
          @categories = []
          return
        end
        counts = @branch.products
                         .of_wechat
                         .available
                         .sale_on_date(params[:date])
                         .on_shelf
                         .by_support_type(params[:support_type])
                         .where(estimate_clear: false)
                         .by_category(@all_categories.map(&:id))
                         .group('ddt_categories_products.category_id')
                         .reorder('min(ddt_products.position)')
                         .count('ddt_products.id')
        root_category = @all_categories.select{|category| category.parent_id.blank?}
        @categories = root_category.select do |category|
          counts[category.id].present? || subs_has_product?(counts, category)
        end
      end

      def subs_has_product?(counts, category)
        subs = @all_categories.select{|c| c.parent_id && c.parent_id == category.id}
        result = false
        subs.each do |sub|
          if counts[sub.id].present?
            result = true
          end
        end
        result
      end

  end
end
