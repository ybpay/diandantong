# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::DeliveryOrderPolicy do

  describe '#assign_delivery_man?' do
    it_behaves_like 'an ApplicationPolicy permission', :delivery_order, :assign_delivery_man
  end

  describe '#start_shipment?' do
    it_behaves_like 'an ApplicationPolicy permission', :delivery_order, :start_shipment
  end

  describe '#finish_shipment?' do
    it_behaves_like 'an ApplicationPolicy permission', :delivery_order, :finish_shipment
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :delivery_order, :create
  end
end
