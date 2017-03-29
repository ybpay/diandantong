module Ddt
  module OrderService
    module Api
      module Mock
        module Model
          class FormContent < ActiveRecord::Base
            self.table_name = "ddt_form_contents"
            belongs_to :order, class_name: "Ddt::OrderService::Api::Mock::Model::Order"
          end
        end
      end
    end
  end
end