module Ddt
  module Backend
    module Statistic
      class TableStatisticsController < Backend::Statistic::BaseController

        STATISTICS = Ddt::TableStatistic::ALL.map(&:info)

        init_statistics STATISTICS
        check_permission :shop, :statistic, :table_statistic
      end
    end
  end
end
