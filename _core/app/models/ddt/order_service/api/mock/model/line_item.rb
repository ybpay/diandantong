module Ddt
  module OrderService
    module Api
      module Mock
        module Model
          class LineItem < ActiveRecord::Base
            self.table_name = "ddt_line_items"
            belongs_to :order, class_name: "Ddt::OrderService::Api::Mock::Model::Order"
            belongs_to :order_change_log, class_name: "Ddt::OrderService::Api::Mock::Model::OrderChangeLog"
            include Discard::Model
            default_scope { kept }
          end
        end
      end
    end
  end
end
