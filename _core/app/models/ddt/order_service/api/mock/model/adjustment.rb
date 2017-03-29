module Ddt
  module OrderService
    module Api
      module Mock
        module Model
          class Adjustment < ActiveRecord::Base
            self.table_name = "ddt_adjustments"
            belongs_to :order, class_name: "Ddt::OrderService::Api::Mock::Model::Order"
            acts_as_paranoid
            scope :root, ->{ where(parent_id: nil)}
            has_many :subs, class_name: '::Ddt::OrderService::Api::Mock::Model::Adjustment', foreign_key: :parent_id
            belongs_to :parent, class_name: '::Ddt::OrderService::Api::Mock::Model::Adjustment', foreign_key: :parent_id
          end
        end
      end
    end
  end
end