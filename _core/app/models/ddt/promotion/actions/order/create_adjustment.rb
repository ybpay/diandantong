module Ddt
  class Promotion
    module Actions
      module Order
        class CreateAdjustment < ::Ddt::PromotionAction
          include Ddt::PromotionActionModelName
          include Ddt::Calculable

          before_validation :ensure_action_has_calculator

          def perform(promotable)
            promotable.adjust(reason: :promotion, source: self)
          end

          concerning :AdjustSource do
            def compute_amount_of_adjustment(order)
              (self.calculator.compute(order) - order.computable_price).round(2)
            end

            def get_label_of_adjustment(order)
              promotion.name
            end

            def need_apportion_adjustment_amount?
              true
            end
          end

          private
            def ensure_action_has_calculator
              if self.calculator.blank?
                self.calculator = Ddt::Calculator::Order::FlatPercent.new
              end
            end
        end
      end
    end
  end
end