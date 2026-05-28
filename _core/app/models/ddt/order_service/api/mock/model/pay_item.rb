module Ddt
  module OrderService
    module Api
      module Mock
        module Model
          class PayItem < ActiveRecord::Base
            self.table_name = "ddt_pay_items"
            belongs_to :order, class_name: "Ddt::OrderService::Api::Mock::Model::Order"
            include Discard::Model
            default_scope { kept }
          end
        end
      end
    end
  end
end