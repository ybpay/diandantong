#encoding: utf-8
module Ddt
  module BusinessStatistic
    class SalesByMonth < Ddt::BusinessStatistic::Sales
      include Ddt::BusinessStatistic::Concern::GroupByTime

      attr_accessor :year, :month
      hash_attrs({
        年份: :year,
        月份: :month
     })

      def self.class_info
        {
          name: 'sales_by_month',
          paginate: false,
          permit_params:[:year, :month, :branch_id, :search_by],
          default_params: this_month,
          label: '营业结算(日)',
          sortable: true,
          expose_to_api: true
        }
      end

      def group_by_column
        :paid_at_month
      end

      def shift_group_by_column
        :created_at_month
      end

      def time_format
        "#{'%02d' % month}-%02d"
      end

      def initialize(options={})
        super
        initialize_month_params(options)
      end

      def filter_blk
        Proc.new{|shift_item| shift_item.paid_at.strftime("%m-%d")}
      end

      def labels
        keys.map do |k|
          wday = Date.new(year, month, k.split('-')[1].to_i).wday
          wlabel = Ddt::TimeUtil.week_label(wday)
          "#{k}<br />#{wlabel}"
        end
      end

      def csv_labels
        keys.map do |k|
          wday = Date.new(year, month, k.split('-')[1].to_i).wday
          "#{k}"
        end
      end

      def keys
        Ddt::TimeUtil.day_labels(month, year)
      end

      def filters
        [
          filter_search_by,
          filter_branch,
          filter_year,
          filter_month
        ]
      end

      def custom_thead?
        true
      end

      def custom_thead
        thead = []
        tr = [
          {name: '科目代码'},
          {name: '科目名称'},
          {name: '合计'},
          {name: '实收'}
        ]
        labels.each{|label| tr << {name: label} }
        thead << tr
        thead
      end

      def title
        %W[科目代码 科目名称 合计 实收] + csv_labels
      end

      def body
        content = []
        shift_item_summarys.each do |pay_method_id, summary|
          row = [
            summary[:pay_method_code],
            summary[:pay_method_name],
            summary[:series]['summary'][:amount],
            summary[:series]['summary'][:actual_amount],
          ]
          keys.each do |key|
            row << summary[:series][key][:amount]
          end
          content << row
        end
        content
      end

      def foot
        default = ['', '', 0, '']
        keys.size.times{ default << 0 }
        row00 = default.clone
        row01 = default.clone
        row1 = default.clone
        row2 = default.clone
        row3 = default.clone
        row00[1] = '折前'
        row01[1] = '折扣'
        row1[1] = '营业合计'
        row2[1] = '实收合计'
        row3[1] = '非实收合计'
        shift_item_summarys.each do |pay_method_id, summary|
          row1[2] += summary[:series]['summary'][:amount]
          row2[2] += summary[:series]['summary'][:actual_amount]
          row3[2] += summary[:series]['summary'][:no_actual_amount]


          keys.each_with_index do |key, index|
            idx = 4 + index
            row1[idx] += summary[:series][key][:amount]
            row2[idx] += summary[:series][key][:actual_amount]
            row3[idx] += summary[:series][key][:no_actual_amount]
          end
        end
        [row1, row2, row3]
      end

      def to_combi_result
        h = {}
        shift_item_summarys.each do |k, summary|
          # k is pay_method_id
          h[k] = {
            pay_method_name:   summary[:pay_method_name],
            pay_method_code:   summary[:pay_method_code],
            amount:            summary[:series]['summary'][:amount],
            actual_amount:     summary[:series]['summary'][:actual_amount],
            not_actual_amount: summary[:series]['summary'][:no_actual_amount]
          }
        end
        h
      end

    end

  end
end
