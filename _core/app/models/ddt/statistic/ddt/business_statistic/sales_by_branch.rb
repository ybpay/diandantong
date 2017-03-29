module Ddt
  module BusinessStatistic
    class SalesByBranch < ::Ddt::BusinessStatistic::Sales
      include Ddt::BusinessStatistic::Concern::GroupByBranch

      def self.class_info
        {
          name: 'sales_by_branch',
          paginate: false,
          permit_params: [:search_by, :start_time, :end_time],
          default_params: this_day,
          label: '营业结算(按店)',
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        @branch_id = ALL_BRANCH
      end

      def filters
        [
          filter_search_by,
          filter_start_time,
          filter_end_time,
        ]
      end

      def by_time
        false
      end

      def by_branch
        true
      end

      def group_by_column
        :branch_id
      end

      def shift_group_by_column
        nil
      end

      def title
        ['门店', '营业合计', '实收', '非实收']
      end

      def body
        content = []
        shift_item_summarys.each do |item|
          row = []
          row << item[:branch_name]
          row << item[:amount]
          row << item[:actual_amount]
          row << item[:not_actual_amount]
          content << row
        end
        content
      end

      def foot
        datas = body
        return [[]]if datas.blank?
        body_data = datas.map{|row| row.shift; row}
        first = body_data.shift
        zip_data = first.zip(*body_data)
        [zip_data.map(&:sum).unshift('总计')]
      end

      def to_combi_result
        shift_item_summarys.inject({}) do |h, item|
          h[item[:branch_id]] = item
          h
        end
      end

    end
  end
end
