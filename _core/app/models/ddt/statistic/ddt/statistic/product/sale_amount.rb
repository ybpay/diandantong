module Ddt
  class Statistic
    module Product
      class SaleAmount < ::Ddt::Statistic::Product::Base
        def query
          variant_sale = OrderService::Api::Statistic.variant_sale_amount(query: query_params, group_by: group_by)
          combo_sale = OrderService::Api::Statistic.combo_sale_amount(query: query_params, group_by: group_by)
          if group_by.to_s == "category_names"
            combo_sale = { "套餐" => combo_sale.values.first }
          end
          variant_sale.merge(combo_sale)
        end

        def query_params
          q.merge({
            shop_id_eq: shop.try(:id),
            branch_id_eq: branch.try(:id),
            created_at_gteq: start_date.beginning_of_day,
            created_at_lteq: end_date.end_of_day
          })
        end
      end
    end
  end
end