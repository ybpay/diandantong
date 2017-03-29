module Ddt
  module Backend
    module Statistic
      class ProductStatisticsController < Backend::Statistic::BaseController

        STATISTICS = Ddt::ProductStatistic::ALL.map(&:info)

        init_statistics STATISTICS
        check_permission :shop, :statistic, :product_statistic
      end
    end
  end
end
