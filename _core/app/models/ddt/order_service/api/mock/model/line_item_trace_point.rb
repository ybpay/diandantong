module Ddt
  module OrderService
    module Api
      module Mock
        module Model
          class LineItemTracePoint < ActiveRecord::Base
            self.table_name = "ddt_line_item_trace_points"
            belongs_to :order, class_name: "Ddt::OrderService::Api::Mock::Model::Order"
            belongs_to :line_item, class_name: "Ddt::OrderService::Api::Mock::Model::LineItem"
            belongs_to :order_change_log, class_name: "Ddt::OrderService::Api::Mock::Model::OrderChangeLog"
          end
        end
      end
    end
  end
end