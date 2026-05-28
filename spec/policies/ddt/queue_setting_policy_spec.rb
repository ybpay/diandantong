# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::QueueSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :queue_setting, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :queue_setting, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :queue_setting, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :queue_setting, :destroy
  end
end
