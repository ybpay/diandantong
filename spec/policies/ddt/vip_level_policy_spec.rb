# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::VipLevelPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :vip_level, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :vip_level, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :vip_level, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :vip_level, :destroy
  end
end
