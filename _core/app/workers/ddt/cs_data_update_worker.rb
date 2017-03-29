# encoding: utf-8
module Ddt
  class CsDataUpdateWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 3, :queue => :normal

    # cs 通过 sidekiq 来调用此任务,请不要随意修改参数和类名
    def perform(branch_id, start_time, end_time)
      Rails.logger.info("[CsDataUpdateWorker] perform branch_id=#{branch_id}, start_time=#{start_time}, end_time=#{end_time}")
      Ddt::CsHelper.update_data(branch_id, start_time, end_time)
    end

  end
end
