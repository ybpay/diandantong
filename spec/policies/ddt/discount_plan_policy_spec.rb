# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::DiscountPlanPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :discount_plan, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :discount_plan, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :discount_plan, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :discount_plan, :destroy
  end
end
