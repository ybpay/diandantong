module Ddt
  module Webpos
    module Coupon
      class GrouponsController < Webpos::BaseController
        include Ddt::Webpos::BaseCouponController
        check_permission :shop, :groupon, { [:available] => :show, [:find_by_code, :exchange_by_code, :exchange_by_id] => :exchange}

        before_action :set_user, only: [:available, :exchange_by_id]
        before_action :set_groupon, only: [:exchange_by_id]

        def available
          @groupons = @user.groupons.available.select{|groupon| groupon.branch_id == @current_branch.id}
        end

        def exchange_by_id
          @groupon.exchange
          render nothing: true
        end

        private

        def set_user
          @user = @current_shop.base_users.find(params[:user_id])
        end

        def set_groupon
          @groupon = @user.groupons.available.find(params[:groupon_id])
        end

      end
    end
  end
end
