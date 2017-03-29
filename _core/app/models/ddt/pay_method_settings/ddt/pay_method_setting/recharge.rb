module Ddt
  class PayMethodSetting
    class Recharge < ::Ddt::PayMethodSetting
      def can_card_deduction?
        false
      end

      def can_vip_card_pay?
        false
      end
    end
  end
end