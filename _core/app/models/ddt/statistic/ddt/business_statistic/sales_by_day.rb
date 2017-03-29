#encoding: utf-8
module Ddt
  module BusinessStatistic
    class SalesByDay < ::Ddt::BusinessStatistic::Sales
      include Ddt::BusinessStatistic::Concern::GroupByTime

      attr_accessor :date
      hash_attrs({
          日期: :date
     })

      def self.class_info
        {
          name: 'sales_by_day',
          paginate: false,
          permit_params: [:date, :branch_id, :search_by],
          default_params: this_day.merge({search_by: 'order_paid_at'}),
          label: '营业结算',
          expose_to_api: true
        }
      end

      def group_by_column
        :paid_at_day
      end

      def shift_group_by_column
        nil
      end

      def time_format
        nil
      end

      def initialize(options={})
        super
        initialize_day_params(options)
      end

      def custom_thead?
        true
      end

      def custom_thead
        thead = []
        tr = [
          {name: '科目代码', th_attrs: {rowspan: '2'}},
          {name: '科目名称', th_attrs: {rowspan: '2'}},
          {name: '合计', th_attrs: {colspan: '2'}},
        ]
        tr2 = [
          {name: '实收'},
          {name: '非实收'}
        ]
        thead << tr
        thead << tr2
      end

      def filters
        [
          filter_search_by,
          filter_branch,
          filter_date
        ]
      end

      def title
        %W[科目代码 科目名称 实收 非实收]
      end

      def body
        content = []
        shift_item_summarys.each do |pay_method_id, summary|
          content << [
            summary[:pay_method_code],
            summary[:pay_method_name],
            summary[:series]['summary'][:actual_amount],
            summary[:series]['summary'][:no_actual_amount]
          ]
        end
        content
      end

      def foot
        default = [[]]
        (title.size - 2).times{ default.push(0)}
        return [default] if body.blank?
        body_data = body.map{|row| row.shift(2); row}
        first = body_data.shift
        zip_data = first.zip(*body_data)
        [zip_data.map(&:sum).unshift('总计').unshift('')]
      end

    end
  end
end
