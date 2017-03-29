module Ddt
  module UserStatistic
    class NewVip < ::Ddt::UserStatistic::Base

      def self.class_info
        {
          name: 'new_vip',
          paginate: false,
          permit_params: [:branch_id, :start_time, :end_time],
          label: '新增会员统计'
        }
      end

      def result
        return @result if @result.present?
        @result = ::Ddt::VipInfo.group("DATE_FORMAT(become_vip_at, '%m-%d')").ransack({
            shop_id_eq: shop.id,
            from_branch_id_eq: branch.try(:id),
            become_vip_at_gteq: start_time,
            become_vip_at_lteq: end_time,
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
