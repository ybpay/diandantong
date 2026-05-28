# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::TickAccountPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :tick_account, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :tick_account, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :tick_account, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :tick_account, :destroy
  end
end
