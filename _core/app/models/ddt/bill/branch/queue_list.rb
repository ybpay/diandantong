module Ddt
  module Bill
    module Branch
      class QueueList < ::Ddt::Bill::Branch::Base
        def content
          text = []
          text << "<CM>排号统计</CM>\n"
          text << "店铺: #{@branch.name}"
          text << "时间: #{@start_time}"
          text << "  至: #{@end_time}\n"
          text << "-"*bill_width('80')
          items.each do |entry|
            line = []
            line << "队列名称: #{entry[:name] rescue nil}"
            line << "总桌数: #{entry[:total] rescue 0}"
            line << "排号中 #{entry[:queueing] rescue 0}"
            line << "就餐数: #{entry[:accepted] rescue 0}"
            line << "就餐率: #{'%.1f%%' % entry[:accepted_rate]}"
            line << "流失数: #{entry[:rejected] rescue 0}"
            line << "流失率: #{'%.1f%%' % entry[:rejected_rate]}"
            text << line.join("\n")
          end
          text << "-"*bill_width('80')
          text << "读取人员: #{@operator.name}"
          text << "读取时间: #{Time.now}"
          text.join("\n")
        end

        def items
          # 获取指定时间内的 GuestQueue，统计总数、入号数
          guest_queues = @branch.guest_queues.where(created_at: @start_time..@end_time).order('created_at asc')

          hash = {}
          guest_queues.each do |guest_queue|
            entry = hash[guest_queue.queue_setting.name] ||= {
              total: 0,
              queueing: 0,
              accepted: 0,
              rejected: 0
            }
            entry[:total] += 1
            case guest_queue.workflow_state
              when 'queueing'
                entry[:queueing] += 1
              when 'accepted'
                entry[:accepted] += 1
              else
                entry[:rejected] += 1
            end
          end

          array = []
          hash.each do |name, entry|
            array << {
                name: name,
                total: entry[:total],
                queueing: entry[:queueing],
                accepted: entry[:accepted],
                accepted_rate: 100.0 * entry[:accepted] / entry[:total],
                rejected: entry[:rejected],
                rejected_rate: 100.0 * entry[:rejected] / entry[:total]
            }
          end
          array
        end
      end
    end
  end
end
