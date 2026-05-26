#encoding: utf-8
module Ddt
  class StatisticsCache < Ddt::DdtEx
    BUSY_QUERY_INTERVAL = Rails.env.production? ? 7500 : 3000

    acts_as_type :state, [:commit, :completed, :exception], %w[提交 完成 出错]
    include Ddt::CarrierWaveBridge
    mount_uploader :result, StatisticsCacheUploader
    mount_uploader :csv, StatisticsCacheUploader
    mount_uploader :xls, StatisticsCacheUploader

    def progress_text
      if self.state.present?
        case self.state
          when 'completed'
            '100%'
          when 'exception'
            '出错'
          else
            self.progress.present? ? "#{self.progress}%" : '计算中'
        end
      else
        '计算中'
      end
    end

    def cost_time_text
      if self.cost_time.present?
        "#{self.cost_time}秒"
      elsif self.is_completed? || self.is_exception?
        '未统计'
      else
        '未开始'
      end
    end

    def operator_name
      Ddt::Account.find(self.operator_id).name rescue ''
    end
  end
end

