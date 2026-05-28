# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::EmailSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :email_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :email_setting, :update
  end
end
