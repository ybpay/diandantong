module Ddt
  module OrderService
    module Order
      module Concern
        module Path
          extend ActiveSupport::Concern
          included do
            url_method_for :weixin_show, :backend_show, :system_weixin_show
          end

          def system_weixin_show_path
            "weixin/shops/#{self.shop_id}/manage?_ng_path=/branches/#{self.branch_id}/orders/#{self.type_str}/#{self.id}"
          end

          def weixin_show_path
            "weixin/shops/#{self.shop_id}/order?_ng_path=/branches/#{self.branch_id}/orders/#{self.type_str}/#{self.id}"
          end

          def weixin_after_pay_path
            "weixin/shops/#{self.shop_id}/order?_ng_path=/branches/#{self.branch_id}/pay_success/#{self.type_str}/#{self.id}"
          end

          def backend_show_path
            "/backend/shops/#{self.shop.slug}/branches/#{self.branch_id}/#{self.type_str}_orders/#{self.id}"
          end
        end
      end
    end
  end
end
