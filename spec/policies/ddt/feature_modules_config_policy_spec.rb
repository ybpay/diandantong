# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::FeatureModulesConfigPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :feature_modules_config, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :feature_modules_config, :update
  end
end
