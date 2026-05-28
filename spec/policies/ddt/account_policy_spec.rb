# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::AccountPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :account, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :account, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :account, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :account, :destroy
  end
end
