#encoding: utf-8
module Ddt
  module OrderDisplay
    class Fastfood < Ddt::OrderDisplay::Base

      def base_info
        data = []
        data << [:eat_in_hall_fast_food_number, '牌号', order.food_number]
        make_detail_desc(data).concat(super)
      end

      def short_addition_info
        data = []
        data << [:eat_in_hall_fast_food_number, '牌号', order.food_number]
        make_detail_desc(data).concat(super)
      end

    end
  end
end
