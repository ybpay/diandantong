module Ddt
  class Role
    class VipInfoManager < Role
      include Role::Builtin
      def permission_set
        base = [:show, :create, :update, :destroy]
        {
          :shop => {
            :account => [:show],
            :role => [:show],
            :shop => [:show, :dashboard, :home],
            :user => [:show, :update, :recharge_card_wallet, :exchange_card_wallet, :exchange_credits_wallet, :get_credits_wallet, :send_coupon, :create, :destroy],
          },
          :branch => {
          }
        }
      end
    end
  end
end
