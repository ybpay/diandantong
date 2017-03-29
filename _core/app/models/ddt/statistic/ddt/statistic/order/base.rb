module Ddt
  class Statistic
    module Order
      class Base < ::Ddt::Statistic::Base
        def base_order_query_params
          if branch.present?
            q.merge({ branch_id_eq: branch.id })
          elsif shop.present?
            q.merge({ shop_id_eq: shop.id })
          elsif sale_employee.present?
            q.merge({ shop_id_in: sale_employee.shop_ids})
          end
        end
      end
    end
  end
end
