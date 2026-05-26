module Ddt
  module UserStatistic
    class SubscriptionUser < ::Ddt::UserStatistic::Base

      def self.class_info
        {
          name: 'subscription_user',
          permit_params: [:branch_id, :start_time, :end_time],
          label: '新增关注统计'
        }
      end

      def result
        return @result if @result.present?
        @result = ::Ddt::User.group("TO_CHAR(created_at, 'MM-DD')").ransack({
            shop_id_eq: shop.id,
            from_branch_id_eq: branch.try(:id),
            created_at_gteq: start_time,
            created_at_lteq: end_time,
          }).result.count
        hash_all = Hash[date_array.map { |v| [v.strftime('%m-%d'), 0] }]
        @result = hash_all.symbolize_keys.merge(@result.symbolize_keys)
      end
      cache_result

      def date_array
        start_time.to_date..end_time.to_date
      end

      def filters
        [
          filter_branch,
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        date_array.map{|date| date.strftime("%m-%d")}
      end

      def body
        [result.values]
      end

    end
  end
end
