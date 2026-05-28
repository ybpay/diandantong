# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ShopPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :shop, :show
  end

  describe '#dashboard?' do
    it_behaves_like 'an ApplicationPolicy permission', :shop, :dashboard
  end

  describe '#home?' do
    it_behaves_like 'an ApplicationPolicy permission', :shop, :home
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :shop, :update
  end
end
