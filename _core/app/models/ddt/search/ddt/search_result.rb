module Ddt
  class SearchResult < Ddt::Base
    include Ddt::BelongsToShop
    # shop_id
    # search_filter_id
    # count
    # model_ids_str
    # timestamps
    belongs_to :search_filter, class_name: 'Ddt::SearchFilter'

    def append_log(result)
      self.log = "" if self.log.blank?
      self.log += "\n #{result}"
      self.save
    end

    def model_ids
      @model_ids ||= (model_ids_str.present? ? model_ids_str.split(',') : [])
    end

  end
end
