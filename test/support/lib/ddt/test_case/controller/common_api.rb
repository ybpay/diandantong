module Ddt
  module TestCase
    module Controller
      class CommonApi < TestCase::Controller::Base
        engine_route_patch use_route: :common_api, format: :json
        setup do
          login_as worker
        end
        let(:shop)   {
          s = Shop.first
          s.present? ? s : create(:shop_with_boss)
          s.alipay_method.update(
            preferred_pid: "preferred_pid",
            preferred_pkey: "preferred_pkey",
            preferred_email: "preferred_email@diandantong.com",
            active: true
          )
          s
        }
        let(:branch) { shop.branches.first }
        let(:user){ shop.users.first }
        let(:vip_level) { create :vip_level, shop: shop}
        let(:vip_user){
          user.vip_info.update(vip_level: vip_level);
          user.card_wallet.recharge(1000, 1000)
          user.credits_wallet.get(1000)
          user;
        }

        let(:boss)   { shop.boss.first }

        let(:table_zone){ create(:table_zone_with_tables, tables_count: 2, branch_id: branch.id, shop_id: shop.id)}
        let(:table){ table_zone.tables[0] }
        let(:another_table){ table_zone.tables[1] }

        let(:arranging_setting){ create(:arranging_setting, shop_id: shop.id, branch_id: branch.id, mode: :free_choice) }
        let(:queue_setting){ create(:queue_setting, shop_id: shop.id, branch_id: branch.id)}
        let(:guest_queue){create(:guest_queue, queue_setting_id: queue_setting.id, branch_id: branch.id)}

        [:worker,:deliveryman,:cook,:chef,:waiter,:cashier,:vip_info_manager,:queue_waiter].each do |roll_name|
          let(roll_name) do
            a = shop.accounts.detect{|a| a.send("is_#{roll_name}?") }
            a.present? ? a : create(roll_name, shop: shop, manage_branch_ids: [branch.id])
          end
        end

        let(:product){ create(:product , branch_id: branch.id ,shop_id: shop.id) }
        let(:variant) { product.master }
        let(:category){create(:category, branch_id: branch.id, shop_id: shop.id)}
        let(:combo){create(:combo_with_items, branch_id: branch.id, shop_id: shop.id)}

        let(:example_eat_in_hall_order){
          OrderService::Order::EatInHall.any_instance.stubs(:need_auto_confirm_after_place?).returns(false)
          cart = OrderService::Cart::EatInHall.new(table: table, branch: branch, track_from: :FromWebpos)
          cart.add(variant)
          order = cart.place
          OrderService::Order::EatInHall.any_instance.unstub(:need_auto_confirm_after_place?)
          order
        }

        let(:example_fastfood_order){
          OrderService::Order::Fastfood.any_instance.stubs(:need_auto_confirm_after_place?).returns(false)
          cart = OrderService::Cart::Fastfood.new(branch: branch, track_from: :FromWebpos)
          cart.add(variant)
          order = cart.place
          OrderService::Order::Fastfood.any_instance.unstub(:need_auto_confirm_after_place?)
          order
        }
        let(:example_delivery_order){
          OrderService::Order::Delivery.any_instance.stubs(:need_auto_confirm_after_place?).returns(false)
          phone_user = create(:phone_user_with_address, shop_id: shop.id)
          shipment = branch.default_shipment(address: phone_user.default_address)
          cart = OrderService::Cart::Delivery.new(branch: branch, user: phone_user, shipment: shipment, track_from: :FromWebpos)
          cart.add(variant)
          order = cart.place
          OrderService::Order::Delivery.any_instance.unstub(:need_auto_confirm_after_place?)
          order
        }
        let(:example_payment_order){
          OrderService::Order::Payment.any_instance.stubs(:need_auto_confirm_after_place?).returns(false)
          cart = OrderService::Cart::Payment.new(branch: branch, payment_price: 100, track_from: :FromWebpos)
          cart.add(variant)
          order = cart.place
          OrderService::Order::Payment.any_instance.unstub(:need_auto_confirm_after_place?)
          order
        }
        let(:example_groupon_order){
          OrderService::Order::Groupon.any_instance.stubs(:need_auto_confirm_after_place?).returns(false)
          groupon_version = create :groupon_version, branch: branch, shop: shop
          cart = OrderService::Cart::Groupon.new(branch: branch, user: user, track_from: :FromWechat)
          cart.add(groupon_version)
          order = cart.place
          OrderService::Order::Groupon.any_instance.unstub(:need_auto_confirm_after_place?)
          order
        }
        let(:example_recharge_order){
          OrderService::Order::Recharge.any_instance.stubs(:need_auto_confirm_after_place?).returns(false)
          recharge_product = create :recharge_product, shop: shop
          cart = OrderService::Cart::Recharge.new(branch: branch, user: user, track_from: :FromWechat)
          cart.add(recharge_product)
          order = cart.place
          OrderService::Order::Recharge.any_instance.unstub(:need_auto_confirm_after_place?)
          order
        }
        let(:example_reservation_order_prepay_for_table){
          OrderService::Order::Reservation.any_instance.stubs(:need_auto_confirm_after_place?).returns(false)
          reservation_time_point = table_zone.reservation_time_points.first
          reservation_info = ReservationInfo.new(branch: branch, shop: shop, reservation_date: 1.day.since, reservation_time_point: reservation_time_point, name: "name", phone: generate(:phone), gender: :male)
          cart = OrderService::Cart::Reservation.new(branch: branch, prepayment_type: :prepay_for_table, reservation_info: reservation_info, pay_method: :pay_on_arrive, track_from: :FromWechat)
          order = cart.place
          OrderService::Order::Reservation.any_instance.unstub(:need_auto_confirm_after_place?)
          order
        }
        let(:example_reservation_order_prepay_for_order){
          OrderService::Order::Reservation.any_instance.stubs(:need_auto_confirm_after_place?).returns(false)
          reservation_time_point = table_zone.reservation_time_points.first
          reservation_info = ReservationInfo.new(branch: branch, shop: shop, reservation_date: 1.day.since, reservation_time_point: reservation_time_point, name: "name", phone: generate(:phone), gender: :male)
          cart = OrderService::Cart::Reservation.new(branch: branch, prepayment_type: :prepay_for_order, reservation_info: reservation_info, pay_method: :pay_on_arrive, track_from: :FromWechat)
          cart.add(variant)
          order = cart.place
          OrderService::Order::Reservation.any_instance.unstub(:need_auto_confirm_after_place?)
          order
        }

        def login_as(account)
          @request.headers['X-Account-Login-Id'] = account.login_id
          @request.headers['X-Account-Authentication-Token'] = account.authentication_token
        end

        def logout
          @request.headers['X-Account-Login-Id'] = nil
          @request.headers['X-Account-Authentication-Token'] = nil
        end

        private
        def p(params={})
          { shop_id: shop.id, branch_id: branch.id }.merge params
        end
      end
    end
  end
end
