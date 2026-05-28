# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ComboPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :combo, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :combo, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :combo, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :combo, :destroy
  end
end
