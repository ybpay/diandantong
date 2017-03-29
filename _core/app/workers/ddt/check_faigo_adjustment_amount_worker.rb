module Ddt
  class CheckFaigoAdjustmentAmountWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 2, :queue => :default

    def perform(slug)
      shop = Ddt::Shop.find(slug)
      shop.branches.limit(30).each_with_index do |branch, index|
        h = (index/8)*3
        Ddt::CheckBranchAdjustmentAmountWorker.perform_in(h.hours, branch.id, '2016-04-01 00:00:00', '2016-10-01 00:00:00')
      end
    end
  end
end