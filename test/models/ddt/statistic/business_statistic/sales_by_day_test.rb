require 'test_helper'
require_relative '../concern/base_test'
module Ddt
  module Statistic
    module BusinessStatistic
      class SalesByDayTest < TestCase::Base
        include Statistic::Concern::BaseTest
        attr_accessor :statistic

        def setup
          @statistic = Ddt::BusinessStatistic::SalesByDay.new(
            shop: shop,
            accessible_branches: [branch],
            branch_id: branch.id,
            date: Time.now.strftime("%F"),
            statistic_name: 'business_statistic',
            request_path: '/fake/path'
          )
        end

        def place_pay_orders
          order = example_eat_in_hall_order
          pay_itemable = OrderService::PayItemable.new(pay_method_name_sym: :pay_on_face, amount: order.total, shop: shop, branch: branch)
          pay_item = order.load_pay_item(pay_itemable)
          order.change_pay_item_to_paid(pay_item)
          pay_item.update(paid_at: 30.minute.ago)
          order.save
        end

        def set_eight_percent_of_actual
          shop.pay_methods.where(name_sym: :pay_on_face).first.update!(percent_of_actual: 80)
        end

        def make_data
          shift = create(:shift, branch_id: branch.id, shop_id: shop.id)
          place_pay_orders
          shift.close
        end

        def test_body_got_result
          make_data
          result = false
          statistic.body.each do |row|
            if row[1] == "现金" && row[2] == 10
              result = true
            end
          end
          assert result
        end

        def test_body_got_result_with_eighty_percent_of_actual
          set_eight_percent_of_actual
          make_data
          result = false
          statistic.body.each do |row|
            if row[1] == "现金" && row[2] == 8
              result = true
            end
          end
          assert result
        end

      end
    end
  end
end
