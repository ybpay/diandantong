module Ddt
  module Backend
    module Statistic
      class CouponStatisticsController < Backend::Statistic::BaseController
        STATISTICS = Ddt::CouponStatistic::ALL.map(&:info)
        init_statistics STATISTICS
        check_permission :shop, :statistic, :coupon_statistic
      end
    end
  end
end
