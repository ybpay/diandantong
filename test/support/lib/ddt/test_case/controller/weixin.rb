module Ddt
  module TestCase
    module Controller
      class Weixin < TestCase::Controller::Base
        engine_route_patch use_route: :weixin, format: :json

        setup{
          Table.any_instance.stubs(:create_qr_code?).returns(false)
        }

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
        let(:user){ shop.users.first }
        let(:vip_level) { create :vip_level, shop: shop}
        let(:vip_user){ user.vip_info.update(vip_level: vip_level); user; }
        let(:branch) { shop.branches.first }
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
        let(:category){ create(:category, branch_id: branch.id, shop_id: shop.id) }
        let(:delivery_zone) { create(:delivery_zone, branch_id: branch.id, shop_id: shop.id)}
        let(:order_promotion){
          promotion = create :order_promotion, shop: shop
          rule = create :promotion_rules_order_item_total, promotion: promotion, preferred_amount_min: 0, preferred_amount_max: 1000
          action = create :promotion_actions_order_create_adjustment_with_flat_reduce_calculator, promotion: promotion, flat_reduce_amount: 1
          promotion
        }
        let(:form_element_text){ create :form_element_text, branch_id: branch.id, shop_id: shop.id}
        let(:form_element_select){ create :form_element_select, branch_id: branch.id, shop_id: shop.id}
        let(:wechat_account){ shop.wechat_accounts.first}
        let(:coupon_version){ create :coupon_version, shop_id: shop.id}
        let(:coupon){ coupon_version.send_coupon_to_user(user, :promotion) }
        let(:nother_coupon){ coupon_version.send_coupon_to_user(user) }

        private
        def p(params={})
          { shop_id: shop.id, branch_id: branch.id, open_id: user.user_open_id }.merge params
        end
      end
    end
  end
end