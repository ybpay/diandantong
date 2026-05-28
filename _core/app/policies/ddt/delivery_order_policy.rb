# frozen_string_literal: true

module Ddt
  class DeliveryOrderPolicy < ApplicationPolicy
    def assign_delivery_man?
      permission_allowed?(:delivery_order, :assign_delivery_man)
    end

    def start_shipment?
      permission_allowed?(:delivery_order, :start_shipment)
    end

    def finish_shipment?
      permission_allowed?(:delivery_order, :finish_shipment)
    end

    def create?
      permission_allowed?(:delivery_order, :create)
    end
  end
end
