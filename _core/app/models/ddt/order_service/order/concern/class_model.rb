module Ddt
  module OrderService
    module Order
      module Concern
        module ClassModel
          extend ActiveSupport::Concern
          included do
            # extend ActiveModel::Naming
          end
          module ClassMethods
            def base_class
              OrderService::Order::Base
            end

            def foreign_key
              :order_id
            end

            # use for polymorphic type polymorphic_url
            def model_name
              if self.name.demodulize == "Base"
                Ddt::Order.model_name
              else
                Ddt.const_get("#{self.name.demodulize}Order").model_name
              end
            end
          end

          def exists?
            true
          end

          def new?
            false
          end
          alias_method :new_record?, :new?

          def marked_for_destruction?
            false
          end

          def cart?
            false
          end
          alias_method :is_cart?, :cart?

          def to_param
            id
          end

          def cache_key
            "order-#{id}-#{total}-#{updated_at.to_i}-#{updated_at.strftime('%6N')}"
          end

          def place_time
            placed_at
          end
        end
      end
    end
  end
end