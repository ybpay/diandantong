# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ZonePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :zone, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :zone, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :zone, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :zone, :destroy
  end
end
