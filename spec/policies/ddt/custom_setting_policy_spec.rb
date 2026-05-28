# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CustomSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :custom_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :custom_setting, :update
  end
end
