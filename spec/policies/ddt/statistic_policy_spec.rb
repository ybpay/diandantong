# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::StatisticPolicy do

  describe '#statistics_cache?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :statistics_cache
  end

  describe '#business_statistic?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :business_statistic
  end

  describe '#coupon_statistic?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :coupon_statistic
  end

  describe '#orders_statistic?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :orders_statistic
  end

  describe '#product_statistic?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :product_statistic
  end

  describe '#table_statistic?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :table_statistic
  end

  describe '#user_statistic?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :user_statistic
  end

  describe '#worker_statistic?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :worker_statistic
  end

  describe '#finance_statistic?' do
    it_behaves_like 'an ApplicationPolicy permission', :statistic, :finance_statistic
  end
end
