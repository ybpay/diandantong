# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ReservationSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :reservation_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :reservation_setting, :update
  end
end
