# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::BranchPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch, :destroy
  end

  describe '#clear_data?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch, :clear_data
  end

  describe '#open_shift?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch, :open_shift
  end

  describe '#close_shift?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch, :close_shift
  end
end
