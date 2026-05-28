# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::BranchGroupPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch_group, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch_group, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch_group, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :branch_group, :destroy
  end
end
