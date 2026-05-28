# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CategoryPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :category, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :category, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :category, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :category, :destroy
  end
end
