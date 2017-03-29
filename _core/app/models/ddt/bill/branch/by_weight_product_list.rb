module Ddt
  module Bill
    module Branch
      class ByWeightProductList < Ddt::Bill::Branch::Base
        attr_accessor :skus

        def initialize(branch, options)
          super
          @statistic = Ddt::ProductStatistic::VariantPackageSummary.new(
            shop: branch.shop,
            branch_id: branch.id,
            start_time: @start_time,
            end_time: @end_time,
            time_interval_id: @time_interval_id,
            is_async: false
          )
        end

        def content
          lines = []
          lines << "称重产品报表"
          lines << "门店: #{@branch.name}"
          lines << "时间: #{@start_time}"
          lines << "  至: #{@end_time}"
          lines << "(以订单支付时间计算)"
          group_items.each do |gitem|
            lines << "[#{gitem[:name]} (单位:#{gitem[:unit_name]})"
            lines << '%-5s  %4s  %4s  %4s  %6s' % %w(项目 数量 称重 金额 金额占比)

            gitem[:variants].each do |v|
              line = '%-5s  %4d  %5.1d  %9.2f    %5.2f%%' % [v[:name], v[:quantity], v[:weight], v[:amount], v[:percent] * 100]
              lines << line
            end
            line = '%-5s  %4d  %5.1d  %9.2f' % ["小计", gitem[:total_quantity], gitem[:total_weight], gitem[:total_amount] ]
            lines << line
            lines << '-' * 44
          end

          lines << '%-5s  %4d  %6s  %9.2f' % ['总数', total_quantity, '' , total_amount]
          lines << '=' * 44

          lines << "读取人员: #{@operator.name}"
          lines << "读取时间: #{Time.now}"

          lines.join("\n")
        end

        def group_items
          @statistic.group_items
        end


        def total_amount
          group_items.map{|gitem| gitem[:total_amount]}.sum.round(2)
        end

        def total_quantity
          group_items.map{|gitem| gitem[:total_quantity]}.sum
        end

      end
    end
  end
end
