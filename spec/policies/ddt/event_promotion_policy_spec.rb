# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::EventPromotionPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :event_promotion, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :event_promotion, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :event_promotion, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :event_promotion, :destroy
  end
end
