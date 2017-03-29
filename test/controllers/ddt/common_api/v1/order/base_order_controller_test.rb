
require 'test_helper'
module Ddt
  module CommonApi
    module V1
      module Order
        module BaseOrderControllerTest
          extend ActiveSupport::Concern

          def test_show
            get :show, p( id: @order.id )
            assert_response 200
            assert_equal json["id"], @order.id
          end

          def test_cancel
            post :cancel, p( id: @order.id, cancel_reason: "cancel_reason" )
            assert_response 200
            assert_equal json["id"], @order.id
          end

          def test_confirm
            post :confirm, p( id: @order.id )
            assert_response 200
            assert_equal json["id"], @order.id
          end

          def test_complete
            @order.confirm
            set_order_paid
            post :complete, p( id: @order.id )
            assert_response 200
            assert_equal json["id"], @order.id
          end

          def test_change_vip_info
            post :change_vip_info, p(id: @order.id, vip_info_id: vip_user.vip_info_id)
            assert_response 200
          end

          def test_unbind_vip_info
            @order.change_vip_info(vip_user.vip_info)
            post :unbind_vip_info, p(id: @order.id)
            assert_response 200
          end

          def test_card_deduction
            wallet = vip_user.vip_info.card_wallet
            pre_amount = wallet.amount
            @order.change_vip_info(vip_user.vip_info)
            @order.update_total_and_save
            pre_order_total = @order.total
            post :card_deduction, p(id: @order.id, amount: 5)
            assert_response 200
            amount = wallet.reload.amount
            order_total = @order.reload.total
            assert_equal (pre_amount - 5).to_f, amount.to_f
            assert_equal (pre_order_total -5).to_f, order_total.to_f
          end

          def test_hasten
            if %w[eat_in_hall fastfood delivery].include? @order.type_str
              post :hasten, p(id: @order.id, track_from: 'FromWebpos')
              assert_response 200
            else
              skip
            end
          end

          private
          def set_order_paid(account=nil)
            @order.operator = account
            pay_itemable = OrderService::PayItemable.new(name_sym: :pay_on_face, amount: @order.total, shop: shop)
            pay_item = @order.load_pay_item(pay_itemable)
            @order.change_pay_item_to_paid(pay_item)
          end

        end
      end
    end
  end
end
