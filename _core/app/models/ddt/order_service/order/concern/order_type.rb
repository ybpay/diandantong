module Ddt
  module OrderService
    module Order
      module Concern
        module OrderType
          extend ActiveSupport::Concern
          included do
            def self.types
              [:delivery, :reservation, :eat_in_hall, :fastfood, :groupon, :recharge, :payment]
            end

            def self.type_str
              self.name.demodulize.underscore
            end
            class << self
              alias_method :display_type, :type_str
            end

            def self.type_collection
              [
                  ['外送', "Ddt::OrderService::Order::Delivery"],
                  ['预订', "Ddt::OrderService::Order::Reservation"],
                  ['堂点', "Ddt::OrderService::Order::EatInHall"],
                  ['快餐', "Ddt::OrderService::Order::Fastfood"],
                  ['团购', "Ddt::OrderService::Order::Groupon"],
                  ['充值', "Ddt::OrderService::Order::Recharge"],
                  ['支付', "Ddt::OrderService::Order::Payment"]
              ]
            end

            def self.base_types
              [
                "Ddt::EatInHallOrder",
                "Ddt::FastfoodOrder",
                "Ddt::DeliveryOrder",
                "Ddt::ReservationOrder",
                "Ddt::PaymentOrder",
                "Ddt::GrouponOrder"
              ]
            end

            def self.recharge_types
              [ "Ddt::RechargeOrder"]
            end

          end

          [:delivery, :reservation, :eat_in_hall, :fastfood, :groupon, :recharge, :payment].each do |order_type|
            define_method "is_#{order_type}?" do
              self.type_str.to_sym == order_type
            end
          end

          def type_str
            self.class.type_str
          end
          alias_method :display_type, :type_str
        end
      end
    end
  end
end
