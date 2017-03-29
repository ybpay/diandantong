module Ddt
  module TestCase
    class Base < ActiveSupport::TestCase
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
      let(:branch) {
        branch = shop.branches.first
        branch.update(promotion_in_webpos: true)
        branch
      }
      let(:user){ shop.users.first }
      let(:vip_level) { create :vip_level, shop: shop}
      let(:vip_user){
        user.vip_info.update(vip_level: vip_level);
        user.card_wallet.recharge(1000, 1000)
        user.credits_wallet.get(1000)
        user;
      }
      let(:boss)   { shop.boss.first }
      [:worker,:deliveryman,:cook,:chef,:waiter,:cashier,:vip_info_manager,:queue_waiter].each do |roll_name|
        let(roll_name) do
          a = shop.accounts.detect{|a| a.send("is_#{roll_name}?") }
          a.present? ? a : create(roll_name, shop: shop, manage_branch_ids: [branch.id])
        end
      end
      let(:table_zone){ create(:table_zone_with_tables, tables_count: 2, branch_id: branch.id, shop_id: shop.id)}
      let(:table){ table_zone.tables[0] }
      let(:another_table){ table_zone.tables[1] }
      let(:product){ create(:product, branch_id: branch.id, shop_id: shop.id) }
      let(:variant){ product.master }
      let(:delivery_zone) { create(:delivery_zone, branch_id: branch.id, shop_id: shop.id)}
      let(:order_promotion){
        promotion = create :order_promotion, shop: shop
        rule = create :promotion_rules_order_item_total, promotion: promotion, preferred_amount_min: 0, preferred_amount_max: 1000
        action = create :promotion_actions_order_create_adjustment_with_flat_reduce_calculator, promotion: promotion, flat_reduce_amount: 1
        promotion
      }
      let(:order_promotion_with_item_discount){
        promotion = create :order_promotion, shop: shop, branch: branch
        rule = create :promotion_rules_order_item_total, promotion: promotion, preferred_amount_min: 0, preferred_amount_max: 1000
        action = create :promotion_actions_order_item_discount, promotion: promotion, preferred_discount: 90
        action.variants << variant
        promotion
      }
      let(:form_element_text){ create :form_element_text, branch_id: branch.id, shop_id: shop.id}
      let(:form_element_select){ create :form_element_select, branch_id: branch.id, shop_id: shop.id}
      let(:coupon_version){ create :coupon_version, shop_id: shop.id}
      let(:coupon){ coupon_version.send_coupon_to_user(user) }
      let(:nother_coupon){ coupon_version.send_coupon_to_user(user, :promotion) }
      let(:product_coupon_version){ create :coupon_version, coupon_type: :product_match, shop_id: shop.id, product_sku: variant.sku}
      let(:product_coupon){ product_coupon_version.send_coupon_to_user(user) }
      let(:voucher_version){ create :voucher_version, shop_id: shop.id}
      let(:voucher){ voucher_version.send_coupon_to_user(user) }
      let(:discount_plan){
        plan = create(:discount_plan, shop: shop, branch: branch)
        item = plan.items.create(item_type: :variant, discount: 0.9)
        item.variants << variant
        plan
      }

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

      def assert_change(expression, message=nil, &block)
        expressions = Array(expression)
        exps = expressions.map { |e| e.respond_to?(:call) ? e : lambda { eval(e, block.binding) }}
        before = exps.map { |e| e.call }
        yield
        expressions.zip(exps).each_with_index do |(code, e), i|
          error = message ? "#{message}.\n#{error}" : "#{code.inspect} didn't change"
          assert_not_equal(before[i], e.call, error)
        end
      end

      def assert_no_change(expressions, message=nil, &block)
        expressions = Array(expressions)
        exps = expressions.map { |e| e.respond_to?(:call) ? e : lambda { eval(e, block.binding) }}
        before = exps.map { |e| e.call }
        yield
        expressions.zip(exps).each_with_index do |(code, e), i|
          error = message ? "#{message}.\n#{error}" : "#{code.inspect} changed"
          assert_equal(before[i], e.call, error)
        end
      end
    end
  end
end
