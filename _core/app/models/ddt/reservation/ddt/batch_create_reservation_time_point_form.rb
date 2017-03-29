#encoding: utf-8
module Ddt
  class BatchCreateReservationTimePointForm
    include ActiveModel::Validations
    attr_accessor :start_time_point, :interval, :count, :table_zone_id, :branch

    validates_presence_of :start_time_point, :interval, :count, :table_zone_id
    validates_numericality_of :interval, :greater_than => 0
    validates_numericality_of :count, :greater_than => 0, :less_than => 16

    def initialize(hash = {})
      hash.each do |key, value|
        self.send(:"#{key}=", value)
      end
    end

    def start_time_point=(time_point)
      # time_point "10:30"
      hour = time_point.split(":")[0].try(:to_i)
      minute = time_point.split(":")[1].try(:to_i) || 0
      @start_time_point = Time.new(2000, 01, 01, hour, minute, 0,"+08:00")
    end

    def interval=(minute)
      @interval = minute.to_i
    end

    def count=(n)
      @count = n.to_i
    end

    def to_key
      nil
    end

    def perform
      Ddt::ReservationTimePoint.transaction do
        time_point = @start_time_point
        count.to_i.times do
          branch.reservation_time_points.create!(time_point: time_point, table_zone_id: table_zone_id, branch_id: branch.id)
          time_point += interval.minute
        end
      end
    end

  end
end
