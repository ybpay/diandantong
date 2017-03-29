# encoding: utf-8
module Ddt
  class TimeInterval < Ddt::Base
    include BelongsToShop
    validates_presence_of :start
    validates_presence_of :interval
    validates_numericality_of :interval, greater_than: 0

    def end
      self.start + self.interval
    end

    def interval_in_hour
      ((interval || 0) / 3600.0).round(2)
    end

    def interval_in_hour=(hour)
      if hour.present?
        self.interval = hour.to_f*3600
      else
        self.interval = 0
      end
    end

    def select_json
      {
          id: self.id,
          name: self.name
      }
    end
  end
end