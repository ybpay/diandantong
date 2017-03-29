module Ddt
  module TestCase
    module Controller
      class OauthApi < TestCase::Controller::Base
        engine_route_patch use_route: :oauth_api, format: :json
        setup do
          token = Doorkeeper::AccessToken.new(resource_owner_id: boss.id)
          ::Ddt::OauthApi::BaseController.any_instance.stubs(:doorkeeper_token).returns(token)
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
        let(:vip_user){ user.vip_info.update(vip_level: vip_level); user; }
        let(:boss)   { shop.boss.first }
        [:worker,:deliveryman,:cook,:chef,:waiter,:cashier,:vip_info_manager,:queue_waiter].each do |roll_name|
          let(roll_name) do
            a = shop.accounts.detect{|a| a.send("is_#{roll_name}?") }
            a.present? ? a : create(roll_name, shop: shop, manage_branch_ids: [branch.id])
          end
        end
      end
    end
  end
end
