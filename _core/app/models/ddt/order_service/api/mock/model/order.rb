module Ddt
  module OrderService
    module Api
      module Mock
        module Model
          class Order < ActiveRecord::Base
            self.table_name = "ddt_orders"
            self.inheritance_column = nil
            has_many :line_items, class_name: "Ddt::OrderService::Api::Mock::Model::LineItem"
            has_many :adjustments, class_name: "Ddt::OrderService::Api::Mock::Model::Adjustment"
            has_many :pay_items, class_name: "Ddt::OrderService::Api::Mock::Model::PayItem"
            has_many :order_change_logs, class_name: "Ddt::OrderService::Api::Mock::Model::OrderChangeLog"
            has_many :form_contents, class_name: "Ddt::OrderService::Api::Mock::Model::FormContent"
            has_many :line_item_trace_points, class_name: "Ddt::OrderService::Api::Mock::Model::LineItemTracePoint"
            include Discard::Model
    default_scope { kept }
          end
        end
      end
    end
  end
end
