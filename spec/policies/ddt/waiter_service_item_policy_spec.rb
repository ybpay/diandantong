# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::WaiterServiceItemPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :waiter_service_item, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :waiter_service_item, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :waiter_service_item, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :waiter_service_item, :destroy
  end
end
