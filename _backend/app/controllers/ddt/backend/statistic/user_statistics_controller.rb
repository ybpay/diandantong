module Ddt
  module Backend
    module Statistic
      class UserStatisticsController < Backend::Statistic::BaseController

        STATISTICS = Ddt::UserStatistic::ALL.map(&:info)

        init_statistics STATISTICS
        check_permission :shop, :statistic, :user_statistic

      end
    end
  end
end
