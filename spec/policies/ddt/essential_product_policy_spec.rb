# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::EssentialProductPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :essential_product, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :essential_product, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :essential_product, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :essential_product, :destroy
  end
end
