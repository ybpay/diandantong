# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::TableZonePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :table_zone, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :table_zone, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :table_zone, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :table_zone, :destroy
  end
end
