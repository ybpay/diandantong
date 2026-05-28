module Ddt
  module OrderService
    module Api
      module Mock
        module Model
          class OrderChangeLog < ActiveRecord::Base
            self.table_name = "ddt_order_change_logs"
            self.inheritance_column = nil
            belongs_to :order, class_name: "Ddt::OrderService::Api::Mock::Model::Order"
            include Discard::Model
    default_scope { kept }
          end
        end
      end
    end
  end
end
