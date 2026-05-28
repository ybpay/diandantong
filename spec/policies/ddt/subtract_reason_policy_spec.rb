# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::SubtractReasonPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :subtract_reason, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :subtract_reason, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :subtract_reason, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :subtract_reason, :destroy
  end
end
