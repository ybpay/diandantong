# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::RolePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :role, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :role, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :role, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :role, :destroy
  end
end
