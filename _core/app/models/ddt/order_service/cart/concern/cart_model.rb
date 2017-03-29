module Ddt
  module OrderService
    module Cart
      module Concern
        module CartModel
          extend ActiveSupport::Concern
          def ==(o)
            false
          end

          def id
            nil
          end

          def cart?
            true
          end
          alias_method :is_cart?, :cart?

          # use for promotion rule
          def place_time
            current_time
          end
        end
      end
    end
  end
end