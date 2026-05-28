# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PayMethodPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :pay_method, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :pay_method, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :pay_method, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :pay_method, :destroy
  end
end
