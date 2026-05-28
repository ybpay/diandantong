# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ComboImagePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :combo_image, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :combo_image, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :combo_image, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :combo_image, :destroy
  end
end
