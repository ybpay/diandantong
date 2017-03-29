module Ddt
  module Bill
    module Branch
      class Base
        include Ddt::BillHelper
        attr_accessor :branch, :start_time, :end_time, :operator, :time_interval_id
        delegate :shop, to: :branch
        delegate :name, to: :operator, prefix: true, allow_nil: true
        def initialize(branch, params)
          @branch = branch
          @operator = params[:operator]
          @start_time = params[:start_time]
          @end_time = params[:end_time]
          @time_interval_id = params[:time_interval_id]
        end

        def time_interval
          if @time_interval.present?
            @time_interval
          elsif @time_interval_id.present?
            @time_inverval = @branch.shop.time_intervals.find(@time_interval_id)
          end
        end
      end
    end
  end
end

