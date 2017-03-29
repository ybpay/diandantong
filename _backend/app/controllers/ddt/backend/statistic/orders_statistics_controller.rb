module Ddt
  module Backend
    module Statistic
      class OrdersStatisticsController < Backend::Statistic::BaseController

        STATISTICS = Ddt::OrdersStatistic::ALL.map(&:info)
        init_statistics STATISTICS
        check_permission :shop, :statistic, :orders_statistic
      end
    end
  end
end
