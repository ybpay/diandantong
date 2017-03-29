#encoding: utf-8
module Ddt
  module BusinessStatistic
    class SalesByWeek < ::Ddt::BusinessStatistic::Sales
      include Ddt::BusinessStatistic::Concern::GroupByTime

      attr_accessor :week, :last_week, :include_last_week
      hash_attrs({
          星期: :week,
          包含上星期: :include_last_week
     })

      def self.class_info
        {
          name: 'sales_by_week',
          paginate: false,
          permit_params: [:week, :branch_id, :search_by],
          default_params: this_week,
          label: '营业结算(周)',
          sortable: true,
          expose_to_api: true
        }
      end

      def group_by_column
        :paid_at_week
      end

      def shift_group_by_column
        :created_at_week
      end

      def time_format
        "%d"
      end

      def initialize(options)
        super
        @search_by = options[:search_by] || 'shift_opened_at'
        @include_last_week = options[:include_last_week]
        initialize_week_params(options)
        if @include_last_week.nil?
          last_week_options = options.dup
          @last_week = self.class.new(last_week_options.merge!(week: @week+1, include_last_week: false))
        end
      end

      def filter_blk
        Proc.new{|shift_item| shift_item.paid_at.strftime("%w")}
      end

      def labels
        Ddt::TimeUtil.week_labels
      end

      def keys
        %W[0 1 2 3 4 5 6]
      end

      def csv_labels
        labels.map{|l| ["#{l}(本周)", "#{l}(上周)", "#{l}(增长率)"]}.flatten
      end

      def filters
        [
          filter_search_by,
          filter_branch,
          filter_week
        ]
      end

      def custom_thead?
        true
      end

      def custom_thead
        thead = []
        tr1 =[
          {name: '科目代码', th_attrs: {rowspan: '2'}},
          {name: '科目名称', th_attrs: {rowspan: '2'}},
          {name: '合计', th_attrs: {colspan: '3'}}
        ]
        labels.each{|label| tr1 << {name: label, th_attrs: {colspan: '3'}} }

        tr2 =[
          {name: '本周'},
          {name: '上周'},
          {name: '增长率'}
        ] * (labels.size + 1)
        thead << tr1
        thead << tr2
        thead
      end

      def title
        %W[科目代码 科目名称 合计(本周) 合计(上周) 合计(增长率)] + csv_labels
      end

      def result_include_last_week
        return @result_include_last_week if @result_include_last_week.present?
        @result_include_last_week = {
          this_week: self.shift_item_summarys,
          last_week: @last_week.shift_item_summarys
        }
      end

      def body
        content = []
        r = result_include_last_week
        last_week_summarys = r[:last_week]
        this_week_summarys = r[:this_week]
        this_week_summarys.each do |pay_method_id, summary|
          last_week_summary = last_week_summarys[pay_method_id]
          summary_amount = (summary[:series]['summary'][:amount] rescue 0)
          last_week_summary_amount = (last_week_summary[:series]['summary'][:amount] rescue 0)
          row = []
          row << summary[:pay_method_code]
          row << summary[:pay_method_name]
          row << summary_amount
          row << last_week_summary_amount
          row << inc_rate_label(summary_amount, last_week_summary_amount)
          keys.each do |key|
            amount = (summary[:series][key][:amount] rescue 0)
            last_amount = (last_week_summary[:series][key][:amount] rescue 0)
            row << amount
            row << last_amount
            row << inc_rate_label(amount, last_amount)
          end
          content << row
        end
        content
      end


      def foot
        default = ['', '', 0, 0, '']
        (keys.size * 3).times{default << 0}
        row1 = default.clone
        row2 = default.clone
        row3 = default.clone
        row1[1] = '营业合计'
        row2[1] = '实收合计'
        row3[1] = '非实收合计'

        r = result_include_last_week
        last_week_summarys = r[:last_week]
        this_week_summarys = r[:this_week]
        this_week_summarys.each do |pay_method_id, summary|

          last_week_summary = last_week_summarys[pay_method_id]
          summary_amount = (summary[:series]['summary'][:amount] rescue 0)
          summary_actual_amount = (summary[:series]['summary'][:actual_amount] rescue 0)
          summary_no_actual_amount = summary_amount - summary_actual_amount

          last_week_summary_amount = (last_week_summary[:series]['summary'][:amount] rescue 0)
          last_week_summary_actual_amount = (last_week_summary[:series]['summary'][:actual_amount] rescue 0)
          last_week_summary_no_actual_amount = last_week_summary_amount - last_week_summary_actual_amount

          row1[2] += summary_amount
          row2[2] += summary_actual_amount
          row3[2] += summary_no_actual_amount

          row1[3] += last_week_summary_amount
          row2[3] += last_week_summary_actual_amount
          row3[3] += last_week_summary_no_actual_amount

          keys.each_with_index do |key, index|
            idx = 5 + (index * 3)

            amount = (summary[:series][key][:amount] rescue 0)
            actual_amount = (summary[:series][key][:actual_amount] rescue 0)
            no_actual_amount = (summary[:series][key][:no_actual_amount] rescue 0)

            last_amount = (last_week_summary[:series][key][:amount] rescue 0)
            last_actual_amount = (last_week_summary[:series][key][:actual_amount] rescue 0)
            last_no_actual_amount = (last_week_summary[:series][key][:no_actual_amount] rescue 0)

            row1[idx] += amount
            row2[idx] += actual_amount
            row3[idx] += no_actual_amount

            row1[idx+1] += last_amount
            row2[idx+1] += last_actual_amount
            row3[idx+1] += last_no_actual_amount

            row1[idx+2] = ''
            row2[idx+2] = ''
            row3[idx+2] = ''
          end

        end
        [row1, row2, row3]
      end

    end
  end
end
