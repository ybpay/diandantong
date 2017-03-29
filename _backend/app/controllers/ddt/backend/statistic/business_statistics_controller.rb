module Ddt
  module Backend
    module Statistic
      class BusinessStatisticsController < Backend::Statistic::BaseController
        STATISTICS = Ddt::BusinessStatistic::ALL.map(&:info)
        init_statistics STATISTICS
        check_permission :shop, :statistic, :business_statistic
      end
    end
  end
end
