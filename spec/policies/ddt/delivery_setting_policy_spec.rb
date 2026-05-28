# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::DeliverySettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :delivery_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :delivery_setting, :update
  end
end
