module Ddt
  class PayMethodSetting
    class Fastfood < ::Ddt::PayMethodSetting
      before_create :set_default
      private

        def set_default
          self.can_pay_on_face = false
          true
        end
    end
  end
end
