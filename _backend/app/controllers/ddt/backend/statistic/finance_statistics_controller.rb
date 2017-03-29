module Ddt
  module Backend
    module Statistic
      class FinanceStatisticsController < Backend::Statistic::BaseController
        STATISTICS = Ddt::FinanceStatistic::ALL.map(&:info)
        init_statistics STATISTICS
        check_permission :shop, :statistic, :finance_statistic
      end
    end
  end
end
