module Ddt
  module Backend
    module Statistic
      class WorkerStatisticsController < Backend::Statistic::BaseController

        STATISTICS = Ddt::WorkerStatistic::ALL.map(&:info)
        init_statistics STATISTICS
        check_permission :shop, :statistic, :worker_statistic
      end
    end
  end
end
