module Ddt
  module OrderService
    module Cart
      class Groupon < Cart::Base
        def evaluate_promotion?
          false
        end

        def to_options
          super
        end

        def pay_method_blacklist
          [:pay_on_receive, :pay_on_arrive]
        end

        concerning :Validation do
          included do
            validate :check_item_count
            validate :check_groupon_max_count_each_user
          end

          def check_groupon_max_count_each_user
            line_items.each do |line_item|
              self.errors[:base] << "#{line_item.itemable_name}已超过最大购买数量" unless line_item.itemable.can_receive_by?(user, line_item.quantity)
            end
          end
        end
      end
    end
  end
end