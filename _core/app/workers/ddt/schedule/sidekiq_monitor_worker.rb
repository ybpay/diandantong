#encoding: utf-8
require 'sidekiq/api'
module Ddt
  module Schedule
    class SidekiqMonitorWorker < Ddt::Schedule::Base
      sidekiq_options :retry => 0, :queue => :critical
      def perform
        if is_production?
          config = Ddt::SidekiqMonitorConfig
          stats = Sidekiq::Stats.new
          workers = Sidekiq::Workers.new

          report = false
          body = []
          stats.queues.keys.each do |queue_name|
            queue = Sidekiq::Queue.new(queue_name)
            limit = config[queue]
            if limit.present? && (queue.size > limit.size || queue.latency > limit.latency)
                report = true
                body << "#{queue_name}长度: #{queue.size}     !!!WARNING!!!"
                body << "#{queue_name}延时: #{queue.latency}    !!!WARNING!!!"
            else
              body << "#{queue_name}长度: #{queue.size}"
              body << "#{queue_name}延时: #{queue.latency}"
            end
          end

          if report
            body << "stats processed: #{stats.processed}"
            body << "stats failed: #{stats.failed}"
            body << "stats queues: #{stats.queues}"
            body << "当前worker: #{workers.size}"
            workers.each do |process_id, thread_id, work|
              body << work.to_s
            end
            BaseMailer.notify(Rails.application.config.dev_mail_group, '[sidekiq监控预警]', body.join("\n"))
          end
        end
      end
    end
  end
end