# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::GrouponVersionPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_version, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_version, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_version, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon_version, :destroy
  end
end
