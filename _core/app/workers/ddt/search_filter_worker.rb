#encoding: utf-8
module Ddt
  class SearchFilterWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 0, :queue => :seldom

    def perform(id)
      search_filter = Ddt::SearchFilter.find_by(id: id)
      search_filter.perform if search_filter.present?
    end
  end
end
