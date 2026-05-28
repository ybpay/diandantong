# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ProductPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :product, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :product, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :product, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :product, :destroy
  end

  describe '#estimate_clear?' do
    it_behaves_like 'an ApplicationPolicy permission', :product, :estimate_clear
  end
end
