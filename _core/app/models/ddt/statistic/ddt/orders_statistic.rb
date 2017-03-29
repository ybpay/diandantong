module Ddt
  module OrdersStatistic
    ALL = [
      Ddt::OrdersStatistic::OrderCountByDay,
      Ddt::OrdersStatistic::OrderCountByMonth,
      Ddt::OrdersStatistic::OrderCountByYear,
      Ddt::OrdersStatistic::OrderCountByBranch,
      Ddt::OrdersStatistic::OrderOrigin,
      Ddt::OrdersStatistic::OrderDiscount,
      Ddt::OrdersStatistic::ChangeLog,
      Ddt::OrdersStatistic::ChangeLogDetail
    ]
  end
end
