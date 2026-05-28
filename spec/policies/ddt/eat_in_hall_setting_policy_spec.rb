# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::EatInHallSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_setting, :update
  end
end
