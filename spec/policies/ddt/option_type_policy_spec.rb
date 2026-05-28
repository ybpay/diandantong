# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::OptionTypePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :option_type, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :option_type, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :option_type, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :option_type, :destroy
  end
end
