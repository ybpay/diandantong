# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CreditsSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :credits_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :credits_setting, :update
  end
end
