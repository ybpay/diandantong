module Ddt
  module OrderService
    module Order
      module Concern
        module PayTest
          extend ActiveSupport::Concern
          def test_init_platform_pay_item
            pay_item = order.load_pay_item(platform_pay_itemable)
            pay_item.payment = nil
            order.init_platform_pay_item
            assert pay_item.payment.present?
          end

          def test_change_pay_item_to_paid
            pay_item = order.load_pay_item(pay_itemable)
            assert_change %W[order.pay_item_state order.paid_at order.order_change_logs.order_pay.count] do
              order.change_pay_item_to_paid(pay_item)
            end
            assert order.is_paid?
          end

          def test_change_pay_item_to_paid_with_tick_for_account
            tick_account = create(:tick_account, branch: branch)
            pay_itemable = OrderService::PayItemable.new(pay_method_name_sym: :tick_for_account, amount: order.total, shop: shop, tick_account_id: tick_account.id)
            pay_item = order.load_pay_item(pay_itemable)
            assert_change %W[tick_account.items.count] do
              order.change_pay_item_to_paid(pay_item)
            end
            assert order.is_paid?
            item = tick_account.items.last
            assert_equal item.amount, order.total
          end

          def test_payment_paid
            payment = order.load_pay_item(platform_pay_itemable).payment
            assert_change %W[order.pay_item_state order.paid_at order.order_change_logs.order_pay.count] do
              order.payment_paid(payment)
            end
            assert order.is_paid?
          end

          def test_update_pay_item
            order.load_pay_item(pay_itemable)
            order.stubs(:amount_for_pay).returns(1)
            order.update_pay_item
            assert_equal 1, order.pay_items.first.amount
          end

          def test_pay_method_name
            order.create_pay_items(pay_itemables)
            assert order.pay_method_name.include?(pay_itemables[0].pay_method.name)
            assert order.pay_method_name.include?(pay_itemables[1].pay_method.name)
          end

          def test_pay_by_default_method
            order.pay_by_default_method
            assert order.paid?
          end

          concerning :LoadPayItem do
            def test_load_pay_item_with_create
              order.clear_pay_items
              pay_item = order.load_pay_item(pay_itemable)
              assert_equal 1, order.pay_items.count
            end

            def test_load_pay_item_with_update
              order.load_pay_item(pay_itemable)
              assert_change "order.pay_method", "order.pay_items.first" do
                assert_no_change "order.pay_items.count" do
                  order.load_pay_item(platform_pay_itemable)
                end
              end
            end

            def test_load_pay_item_without_change
              order.load_pay_item(pay_itemable)
              assert_no_change "order.pay_method", "order.pay_items.first" do
                order.load_pay_item(pay_itemable)
              end
            end

            def test_load_pay_item_change_settle_account
              order.operator = worker
              assert_change "order.settle_account" do
                order.load_pay_item(pay_itemable)
              end
            end
          end

          concerning :CreatePayItems do
            def test_create_pay_items_with_not_enough_amount
              pay_itemables = OrderService::PayItemable.init_list([], shop: shop)
              order.create_pay_items(pay_itemables)
              assert order.errors.present?
            end

            def test_create_pay_items_with_enough_amount
              assert_change %W[order.pay_items.count order.pay_method_names] do
                order.create_pay_items(pay_itemables)
              end
            end

            def test_create_pay_items_with_tick_for_account
              tick_account = create(:tick_account, branch: branch)
              pay_itemables = OrderService::PayItemable.init_list([
                {pay_method_name_sym: :tick_for_account, amount: order.total, tick_account_id: tick_account.id},
              ], shop: shop)
              order.create_pay_items(pay_itemables)
              assert_equal order.pay_items.count, 1
              assert_equal order.pay_items.first.tick_account_id, tick_account.id
              assert_equal order.pay_items.first.tick_account_name, tick_account.name
            end
          end

          def test_clear_pay_items
            order.clear_pay_items
            assert_equal "none", order.pay_item_state
            assert_equal 0, order.pay_items.count
          end

          def test_pay_all_pay_items
            order.create_pay_items(pay_itemables)
            assert_change %w[order.pay_item_state order.paid_at order.order_change_logs.order_pay.count] do
              order.pay_all_pay_items
            end
          end

          concerning :AntiSettlement do
            def test_do_anti_settlement
              order.create_pay_items(pay_itemables)
              order.pay_all_pay_items
              assert_change %w[order.pay_item_state order.paid_at order.anti_settlement] do
                order.do_anti_settlement
              end
            end
          end

          def test_can_clear_pay_items_false_with_paid_platform_pay_item
            pay_item = order.load_pay_item(platform_pay_itemable)
            pay_item.stubs(:is_paid?).returns(true)
            assert_equal false, order.can_clear_pay_items?
          end

          def test_append_pay_item
            pay_item = order.load_pay_item(pay_itemable)
            order.pay_all_pay_items
            order.confirm if order.can_confirm?
            order.complete
            assert_change %W[order.pay_item_total order.pay_items.count] do
              order.append_pay_item(append_pay_itemable, "description")
            end
          end

          private
          def pay_itemable
            OrderService::PayItemable.new(pay_method_name_sym: :pay_on_face, amount: order.total, shop: shop)
          end

          def append_pay_itemable
            OrderService::PayItemable.new(pay_method_name_sym: :pay_on_face, amount: 10, shop: shop)
          end

          def platform_pay_itemable
            OrderService::PayItemable.new(pay_method_name_sym: :alipay, amount: order.total, shop: shop)
          end

          def pay_itemables
            OrderService::PayItemable.init_list([
              {pay_method_name_sym: :pay_on_face, amount: order.total - 1},
              {pay_method_name_sym: :bank_card_pay, amount: 1},
            ], shop: shop)
          end
        end
      end
    end
  end
end
