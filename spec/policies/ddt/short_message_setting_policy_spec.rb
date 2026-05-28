# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ShortMessageSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :short_message_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :short_message_setting, :update
  end
end
