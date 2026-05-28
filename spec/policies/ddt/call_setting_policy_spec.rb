# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CallSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :call_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :call_setting, :update
  end
end
