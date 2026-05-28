# frozen_string_literal: true

module Ddt
  class StatisticPolicy < ApplicationPolicy
    def statistics_cache?
      permission_allowed?(:statistic, :statistics_cache)
    end

    def business_statistic?
      permission_allowed?(:statistic, :business_statistic)
    end

    def coupon_statistic?
      permission_allowed?(:statistic, :coupon_statistic)
    end

    def orders_statistic?
      permission_allowed?(:statistic, :orders_statistic)
    end

    def product_statistic?
      permission_allowed?(:statistic, :product_statistic)
    end

    def table_statistic?
      permission_allowed?(:statistic, :table_statistic)
    end

    def user_statistic?
      permission_allowed?(:statistic, :user_statistic)
    end

    def worker_statistic?
      permission_allowed?(:statistic, :worker_statistic)
    end

    def finance_statistic?
      permission_allowed?(:statistic, :finance_statistic)
    end
  end
end
